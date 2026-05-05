// background.js — URL Shield Pro

const FLASK_API    = "http://localhost:5002/api/scan";
const FLASK_HEALTH = "http://localhost:5002/api/stats";
const CACHE_TTL    = 1000 * 60 * 30;

// ── FLASK STATUS ──────────────────────────────────────────────────────────────
let flaskOnline = false;
let checking = false;

async function checkFlaskStatus() {
  if (checking) return flaskOnline;
  checking = true;
  try {
    const res = await fetch(FLASK_HEALTH, {
      method: "GET",
      cache: "no-store",
      signal: AbortSignal.timeout(2000)
    });
    flaskOnline = res.ok;
  } catch {
    flaskOnline = false;
  }
  checking = false;
  chrome.storage.local.set({ flaskOnline });
  return flaskOnline;
}

// Poll every 5 seconds
setInterval(checkFlaskStatus, 5002);
checkFlaskStatus();

// ── WHITELIST ─────────────────────────────────────────────────────────────────
const WHITELIST = [
  "google.com","youtube.com","github.com","stackoverflow.com",
  "wikipedia.org","amazon.com","microsoft.com","apple.com",
  "mozilla.org","cloudflare.com","reddit.com","twitter.com",
  "facebook.com","instagram.com","linkedin.com","netflix.com"
];

function isWhitelisted(url) {
  try {
    const h = new URL(url).hostname.replace(/^www\./, "");
    return WHITELIST.some(w => h === w || h.endsWith("." + w));
  } catch { return false; }
}

// ── CACHE ─────────────────────────────────────────────────────────────────────
async function cacheGet(url) {
  const key = "c_" + btoa(encodeURIComponent(url)).slice(0, 40);
  const data = await chrome.storage.local.get(key);
  const entry = data[key];
  if (entry && Date.now() - entry.ts < CACHE_TTL) return entry;
  return null;
}

async function cacheSet(url, result) {
  const key = "c_" + btoa(encodeURIComponent(url)).slice(0, 40);
  result.ts = Date.now();
  await chrome.storage.local.set({ [key]: result });
  const h = await chrome.storage.local.get("history");
  const history = h.history || [];
  history.unshift({ url, verdict: result.verdict, score: result.score, time: new Date().toISOString() });
  if (history.length > 100) history.pop();
  await chrome.storage.local.set({ history });
}

// ── OFFLINE RESULT ────────────────────────────────────────────────────────────
function offlineResult(url) {
  return {
    url, verdict: "offline", score: 0,
    signals: [{ text: "Flask API is offline — start app.py first", severity: "warn" }],
    cached: false
  };
}

// ── SCAN ──────────────────────────────────────────────────────────────────────
async function scanURL(url) {
  if (!url
    || url.startsWith("chrome://")
    || url.startsWith("chrome-extension://")
    || url.startsWith("about:")
    || url.startsWith("edge://")) return null;

  // HARD BLOCK — always do a live check, never trust cached variable alone
  const isUp = await checkFlaskStatus();
  if (!isUp) return offlineResult(url);

  if (isWhitelisted(url)) {
    return { url, verdict: "safe", score: 0, signals: [{ text: "Trusted domain", severity: "safe" }], cached: false };
  }

  const cached = await cacheGet(url);
  if (cached) return { ...cached, cached: true };

  try {
    const res = await fetch(FLASK_API, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ url }),
      signal: AbortSignal.timeout(8000)
    });
    if (!res.ok) throw new Error("status " + res.status);
    const result = await res.json();
    await cacheSet(url, result);
    return result;
  } catch (err) {
    flaskOnline = false;
    chrome.storage.local.set({ flaskOnline: false });
    return offlineResult(url);
  }
}

// ── BADGE ─────────────────────────────────────────────────────────────────────
function updateBadge(tabId, verdict) {
  const colors = { safe:"#22c55e", suspicious:"#f59e0b", dangerous:"#ef4444", offline:"#9ca3af" };
  const labels  = { safe:"✓", suspicious:"!", dangerous:"✕", offline:"–" };
  chrome.action.setBadgeBackgroundColor({ color: colors[verdict] || "#6366f1", tabId });
  chrome.action.setBadgeText({ text: labels[verdict] || "?", tabId });
}

// ── TAB LISTENER ──────────────────────────────────────────────────────────────
chrome.tabs.onUpdated.addListener(async (tabId, changeInfo, tab) => {
  if (changeInfo.status !== "complete" || !tab.url) return;

  // If already known offline, set badge and stop immediately
  if (!flaskOnline) {
    const result = offlineResult(tab.url);
    await chrome.storage.local.set({ [`tab_${tabId}`]: result });
    updateBadge(tabId, "offline");
    try { chrome.tabs.sendMessage(tabId, { type: "SCAN_RESULT", result }); } catch {}
    return;
  }

  await chrome.storage.local.set({ [`tab_${tabId}`]: { verdict: "scanning", url: tab.url, score: 0, signals: [] } });
  chrome.action.setBadgeText({ text: "...", tabId });
  chrome.action.setBadgeBackgroundColor({ color: "#6366f1", tabId });
  try { chrome.tabs.sendMessage(tabId, { type: "SCANNING", url: tab.url }); } catch {}

  const result = await scanURL(tab.url);
  if (!result) return;

  await chrome.storage.local.set({ [`tab_${tabId}`]: result });
  updateBadge(tabId, result.verdict);
  try { chrome.tabs.sendMessage(tabId, { type: "SCAN_RESULT", result }); } catch {}
});

// ── MESSAGES ──────────────────────────────────────────────────────────────────
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {

  if (msg.type === "SCAN_HOVER") {
    // HARD BLOCK for hover scans too
    if (!flaskOnline) {
      sendResponse(offlineResult(msg.url));
      return true;
    }
    scanURL(msg.url).then(r => sendResponse(r));
    return true;
  }

  if (msg.type === "GET_RESULT") {
    chrome.tabs.query({ active: true, currentWindow: true }, async (tabs) => {
      if (!tabs[0]) return sendResponse(null);
      const data = await chrome.storage.local.get(`tab_${tabs[0].id}`);
      sendResponse(data[`tab_${tabs[0].id}`] || null);
    });
    return true;
  }

  if (msg.type === "GET_HISTORY") {
    chrome.storage.local.get("history", d => sendResponse(d.history || []));
    return true;
  }
});

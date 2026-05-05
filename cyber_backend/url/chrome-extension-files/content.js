// content.js — URL Shield Pro

(function () {
  if (window.__urlShieldV2) return;
  window.__urlShieldV2 = true;

  const hoverCache = {};

  function hostname(url) { try { return new URL(url).hostname; } catch { return url; } }
  function normalizeUrl(raw) {
    if (!raw) return null;
    raw = raw.trim();
    if (raw.startsWith("javascript:") || raw.startsWith("mailto:") || raw.startsWith("#")) return null;
    if (!raw.startsWith("http")) { try { raw = new URL(raw, location.href).href; } catch { return null; } }
    return raw;
  }

  // ── TOAST ────────────────────────────────────────────────────────────────────
  const toast = document.createElement("div");
  toast.id = "__ush_toast";
  toast.innerHTML = `
    <div id="__ush_t_inner">
      <div id="__ush_t_icon">⟳</div>
      <div id="__ush_t_body">
        <div id="__ush_t_title">Scanning...</div>
        <div id="__ush_t_sub"></div>
      </div>
      <button id="__ush_t_close">✕</button>
    </div>
  `;
  document.body.appendChild(toast);
  document.getElementById("__ush_t_close").onclick = () => toast.classList.remove("ush-show");

  // ── HOVER POPUP ───────────────────────────────────────────────────────────────
  const hover = document.createElement("div");
  hover.id = "__ush_hover";
  hover.innerHTML = `
    <div id="__ush_h_icon">⟳</div>
    <div id="__ush_h_body">
      <div id="__ush_h_verdict">Scanning...</div>
      <div id="__ush_h_url"></div>
    </div>
    <div id="__ush_h_score"></div>
  `;
  document.body.appendChild(hover);

  // ── SHOW TOAST ────────────────────────────────────────────────────────────────
  let toastTimer;
  function showToast(verdict, title, sub) {
    clearTimeout(toastTimer);
    toast.className = `ush-show ush-${verdict}`;
    document.getElementById("__ush_t_icon").textContent  = { safe:"✓", suspicious:"!", dangerous:"✕", scanning:"⟳", offline:"–" }[verdict] || "–";
    document.getElementById("__ush_t_title").textContent = title;
    document.getElementById("__ush_t_sub").textContent   = sub || "";
    const delay = verdict === "safe" ? 3500 : verdict === "suspicious" ? 7000 : verdict === "offline" ? 3000 : 0;
    if (delay) toastTimer = setTimeout(() => toast.classList.remove("ush-show"), delay);
  }

  // ── SHOW HOVER ────────────────────────────────────────────────────────────────
  let hoverTimer, currentAnchor;
  function showHover(x, y, verdict, verdictText, url, score) {
    hover.className = `ush-show ush-${verdict}`;
    document.getElementById("__ush_h_icon").textContent    = { safe:"✓", suspicious:"!", dangerous:"✕", scanning:"⟳", offline:"–" }[verdict] || "–";
    document.getElementById("__ush_h_verdict").textContent = verdictText;
    document.getElementById("__ush_h_url").textContent     = hostname(url);
    document.getElementById("__ush_h_score").textContent   = score != null ? score + "/100" : "";
    positionHover(x, y);
  }
  function positionHover(x, y) {
    const w = 270, h = 52;
    let left = x + 14, top = y + 14;
    if (left + w > window.innerWidth  - 8) left = x - w - 8;
    if (top  + h > window.innerHeight - 8) top  = y - h - 8;
    hover.style.left = left + "px";
    hover.style.top  = top  + "px";
  }

  // ── MOUSE EVENTS ─────────────────────────────────────────────────────────────
  document.addEventListener("mouseover", (e) => {
    const a = e.target.closest("a[href]");
    if (!a) return;
    const url = normalizeUrl(a.getAttribute("href"));
    if (!url || a === currentAnchor) return;
    currentAnchor = a;
    clearTimeout(hoverTimer);

    // *** HARD BLOCK — check Flask status FIRST before anything ***
    chrome.storage.local.get("flaskOnline", (data) => {
      if (!data.flaskOnline) {
        // Flask is offline — do NOT scan, do NOT show hover popup at all
        hover.className = "";
        return;
      }

      // Flask is online — proceed with scan
      if (hoverCache[url]) {
        const r = hoverCache[url];
        showHover(e.clientX, e.clientY, r.verdict,
          { safe:"Safe", suspicious:"Suspicious", dangerous:"Dangerous!", offline:"Offline" }[r.verdict] || r.verdict,
          url, r.score);
        return;
      }

      showHover(e.clientX, e.clientY, "scanning", "Scanning...", url, null);

      chrome.runtime.sendMessage({ type: "SCAN_HOVER", url }, (r) => {
        if (!r || currentAnchor !== a) return;
        hoverCache[url] = r;
        showHover(e.clientX, e.clientY, r.verdict,
          { safe:"Safe", suspicious:"Suspicious", dangerous:"Dangerous!", offline:"Offline" }[r.verdict] || r.verdict,
          url, r.score);
      });
    });
  }, true);

  document.addEventListener("mousemove", (e) => {
    if (e.target.closest("a[href]") === currentAnchor && currentAnchor)
      positionHover(e.clientX, e.clientY);
  }, true);

  document.addEventListener("mouseout", (e) => {
    if (e.target.closest("a[href]") === currentAnchor) {
      hoverTimer = setTimeout(() => { hover.className = ""; currentAnchor = null; }, 200);
    }
  }, true);

  // ── MESSAGES FROM BACKGROUND ──────────────────────────────────────────────────
  chrome.runtime.onMessage.addListener((msg) => {
    if (msg.type === "SCANNING") {
      // Only show scanning toast if Flask is online
      chrome.storage.local.get("flaskOnline", (data) => {
        if (data.flaskOnline) showToast("scanning", "Scanning...", hostname(msg.url));
      });
    }
    if (msg.type === "SCAN_RESULT") {
      const r = msg.result;
      if (r.verdict === "offline") return; // silence offline results — don't show any toast
      const labels = { safe:"✅ Safe Website", suspicious:"⚠️ Suspicious Website", dangerous:"🚨 Dangerous Website!" };
      const sub = r.signals && r.signals.length && r.verdict !== "safe"
        ? r.signals[0].text
        : `Risk score: ${r.score}/100`;
      showToast(r.verdict, labels[r.verdict] || r.verdict, sub);
    }
  });

  // *** Page load — only show scanning toast if Flask is actually online ***
  chrome.storage.local.get("flaskOnline", (data) => {
    if (data.flaskOnline) {
      showToast("scanning", "Scanning...", location.hostname);
    }
    // If Flask is offline — show nothing, do nothing
  });

})();

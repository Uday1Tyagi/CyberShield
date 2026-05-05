// popup.js — URL Shield Pro

const ICONS  = { safe:"✓", suspicious:"!", dangerous:"✕", scanning:"⟳" };
const LABELS = { safe:"Safe Website", suspicious:"Suspicious", dangerous:"Dangerous!", scanning:"Scanning..." };
const BAR_COLOR = { safe:"#22c55e", suspicious:"#f59e0b", dangerous:"#ef4444", scanning:"#6366f1" };

// ── CHECK FLASK STATUS ────────────────────────────────────────────────────────
fetch("http://localhost:5002/api/stats")
  .then(r => r.json())
  .then(() => {
    document.getElementById("flaskDot").className = "flask-dot dot-on";
    document.getElementById("flaskStatus").textContent = "Flask API connected ✓";
  })
  .catch(() => {
    document.getElementById("flaskDot").className = "flask-dot dot-off";
    document.getElementById("flaskStatus").textContent = "Flask API offline — start app.py";
  });

// ── RENDER RESULT ─────────────────────────────────────────────────────────────
function renderResult(result) {
  const content = document.getElementById("mainContent");
  if (!result) {
    content.innerHTML = `<div class="loading">No scan data yet.<br><small style="opacity:.5">Reload the page to trigger a scan.</small></div>`;
    return;
  }

  const v    = result.verdict || "scanning";
  const score = result.score  || 0;
  const pct   = Math.min(score, 100);
  let url = result.url || "";
  let host = url; try { host = new URL(url).hostname; } catch {}

  // Signals HTML
  let sigsHtml = "";
  if (result.signals && result.signals.length > 0) {
    sigsHtml = `
      <div class="sigs">
        <div class="sigs-lbl">Signals</div>
        ${result.signals.slice(0, 5).map(s => `
          <div class="sig">
            <div class="sig-dot d-${s.severity || 'warn'}"></div>
            ${s.text}
          </div>`).join("")}
      </div>`;
  }

  content.innerHTML = `
    <div class="card v-${v}">
      <div class="card-lbl">Current site</div>
      <div class="verdict-row">
        <div class="v-icon">${ICONS[v] || "?"}</div>
        <div>
          <div class="v-title">${LABELS[v] || v}</div>
          <div class="v-url">${host}</div>
        </div>
      </div>
      <div class="score-wrap">
        <div class="score-lbl"><span>Risk Score</span><span>${score}/100</span></div>
        <div class="score-track">
          <div class="score-fill" style="width:${pct}%;background:${BAR_COLOR[v]}"></div>
        </div>
      </div>
    </div>
    ${sigsHtml}
  `;
}

// ── RENDER HISTORY ────────────────────────────────────────────────────────────
function renderHistory(history) {
  if (!history || history.length === 0) return;
  const sec  = document.getElementById("histSection");
  const list = document.getElementById("histList");
  sec.style.display = "block";

  const dotColor = { safe:"#22c55e", suspicious:"#f59e0b", dangerous:"#ef4444" };
  list.innerHTML = history.slice(0, 7).map(item => {
    let host = item.url; try { host = new URL(item.url).hostname; } catch {}
    return `
      <div class="hist-item">
        <div class="h-dot" style="background:${dotColor[item.verdict] || '#6366f1'}"></div>
        <div class="h-url">${host}</div>
        <div class="h-badge hb-${item.verdict}">${item.verdict}</div>
      </div>`;
  }).join("");
}

// ── LOAD DATA ─────────────────────────────────────────────────────────────────
chrome.runtime.sendMessage({ type: "GET_RESULT" },  renderResult);
chrome.runtime.sendMessage({ type: "GET_HISTORY" }, renderHistory);

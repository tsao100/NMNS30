// 25 異性相吸：帶電物體靜止及運動現象
NMNS.register(25, function (root) {
  var W = 640, Hh = 400, cv = makeCanvas(W, Hh), g = cv.g, m = msgBar(), KC = 1.5e6, EPS = 400;
  var LV = [
    { s: [40, 120], v: [130, 0], t: [585, 300], fx: [], k: 2 },
    { s: [40, 200], v: [140, 0], t: [585, 200], fx: [[320, 200, 1]], k: 3 },
    { s: [40, 340], v: [110, -50], t: [585, 70], fx: [[330, 190, -1], [450, 300, 1]], k: 3 },
    { s: [60, 60], v: [150, 40], t: [100, 340], fx: [[300, 200, 1], [200, 120, 1]], k: 4 }
  ];
  var lvl = 0, placed = [], sign = 1, won = false, anim = 0, L;
  var signBtn = h("div", { class: "row" });

  function sim(extra) {
    var ch = L.fx.map(function (c) { return { x: c[0], y: c[1], q: c[2] }; }).concat(placed), p = { x: L.s[0], y: L.s[1], vx: L.v[0], vy: L.v[1] }, pts = [[p.x, p.y]], best = 1e9, dt = .02;
    for (var i = 0; i < 700; i++) {
      var ax = 0, ay = 0, dead = false;
      ch.forEach(function (c) {
        var dx = p.x - c.x, dy = p.y - c.y, r2 = dx * dx + dy * dy, r = Math.sqrt(r2) || 1e-6;
        if (r < 8) dead = true; var f = KC * c.q / (r2 + EPS);     // 庫侖力：與距離平方成反比；同號為正（相斥）
        ax += f * dx / r; ay += f * dy / r;
      });
      p.vx += ax * dt; p.vy += ay * dt; p.x += p.vx * dt; p.y += p.vy * dt; pts.push([p.x, p.y]);
      best = Math.min(best, Math.hypot(p.x - L.t[0], p.y - L.t[1]));
      if (dead || p.x < -20 || p.x > W + 20 || p.y < -20 || p.y > Hh + 20) break;
    }
    return { pts: pts, hit: best <= 20, best: best };
  }
  function drawBase(upTo) {
    g.fillStyle = "#0f172a"; g.fillRect(0, 0, W, Hh);
    g.fillStyle = "#22c55e"; g.beginPath(); g.arc(L.t[0], L.t[1], 20, 0, 7); g.fill(); g.fillStyle = "#052e16"; g.font = "bold 12px sans-serif"; g.textAlign = "center"; g.fillText("目標", L.t[0], L.t[1] + 4);
    L.fx.concat(placed.map(function (c) { return [c.x, c.y, c.q]; })).forEach(function (c) {
      g.fillStyle = c[2] > 0 ? "#ef4444" : "#3b82f6"; g.beginPath(); g.arc(c[0], c[1], 13, 0, 7); g.fill(); g.fillStyle = "#fff"; g.font = "bold 18px sans-serif"; g.fillText(c[2] > 0 ? "+" : "−", c[0], c[1] + 6);
    });
    g.fillStyle = "#fbbf24"; g.beginPath(); g.arc(L.s[0], L.s[1], 8, 0, 7); g.fill(); g.fillStyle = "#111"; g.font = "bold 12px sans-serif"; g.fillText("+", L.s[0], L.s[1] + 4);
    g.strokeStyle = "#fbbf24"; g.beginPath(); g.moveTo(L.s[0], L.s[1]); g.lineTo(L.s[0] + L.v[0] / 3, L.s[1] + L.v[1] / 3); g.stroke();
  }
  function preview() {
    anim++; var r = sim(); drawBase();
    g.strokeStyle = r.hit ? "#4ade80" : "#94a3b8"; g.setLineDash([5, 5]); g.lineWidth = 2; g.beginPath(); r.pts.forEach(function (p, i) { i ? g.lineTo(p[0], p[1]) : g.moveTo(p[0], p[1]); }); g.stroke(); g.setLineDash([]);
    return r;
  }
  async function launch() {
    var my = ++anim, r = sim(); if (won) return;
    for (var i = 0; i < r.pts.length; i += 3) { if (my !== anim) return; drawBase(); g.strokeStyle = "#fbbf24"; g.lineWidth = 3; g.beginPath(); for (var k = 0; k <= i; k++) k ? g.lineTo(r.pts[k][0], r.pts[k][1]) : g.moveTo(r.pts[k][0], r.pts[k][1]); g.stroke(); await sleep(12); }
    if (r.hit) { won = true; m.say("命中目標！" + (lvl + 1 < LV.length ? "按「下一關」。" : "全部通關！"), "ok"); nb.disabled = lvl + 1 >= LV.length; }
    else m.say("沒打中（最近距離 " + r.best.toFixed(0) + "）。調整電荷的位置或正負再試。", "bad");
  }
  function lvlStart() { L = LV[lvl]; placed = []; won = false; nb.disabled = true; preview(); m.say("第 " + (lvl + 1) + " / " + LV.length + " 關：黃色小球帶正電（+），要讓它碰到綠色目標。點畫面放電荷（最多 " + L.k + " 個），按「發射」。同號相斥、異號相吸。", "info"); }
  function setSign(s) { sign = s; renderSign(); }
  function renderSign() { signBtn.innerHTML = "放置的電荷："; signBtn.append(btn("＋ 正電（紅）", function () { setSign(1); }, "choice" + (sign > 0 ? " sel" : "")), btn("－ 負電（藍）", function () { setSign(-1); }, "choice" + (sign < 0 ? " sel" : "")), btn("撤銷", function () { placed.pop(); preview(); }, "alt sm")); }
  cv.c.addEventListener("click", function (e) {
    if (won) return; var p = canvasPos(cv.c, e);
    var i = placed.findIndex(function (c) { return Math.hypot(c.x - p.x, c.y - p.y) < 14; });
    if (i >= 0) placed.splice(i, 1); else if (placed.length >= L.k) { m.say("電荷用完了，點已放的電荷可拿掉。", "bad"); return; } else placed.push({ x: p.x, y: p.y, q: sign });
    var r = preview(); if (r.hit) m.say("預覽顯示會命中！按「發射」。", "ok");
  });
  var nb = btn("下一關", function () { lvl++; lvlStart(); }); nb.disabled = true;
  root.append(m.el, signBtn, cv.c, h("div", { class: "row" }, btn("發射", launch), btn("清除電荷", function () { placed = []; won = false; preview(); }, "alt"), nb),
    h("p", { class: "link" }, "庫侖定律：電力 F = k·Q₁Q₂ / r²，距離越近力越大。同性電荷互相排斥，異性電荷互相吸引；電荷不是靜止就是在受力下加速運動。虛線是預測軌跡。"));
  renderSign(); lvlStart();
});

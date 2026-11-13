// 23 嫦娥登月：重力及加速度概念
NMNS.register(23, function (root) {
  captureArrows();
  var W = 640, Hh = 460, GY = 420, ALT0 = 500, cv = makeCanvas(W, Hh), g = cv.g, m = msgBar(), hud = h("div", { class: "msg info mono" });
  var LV = [["月球", 1.62, 4, 60], ["地球", 9.8, 20, 80], ["月球（燃料少）", 1.62, 4, 50]];
  var lv = 0, wins = 0, S, timer = 0, padx;
  function start() {
    var L = LV[lv]; padx = 120 + rnd(400);
    S = { nm: L[0], g: L[1], tmax: L[2], fuel: L[3], alt: ALT0, vy: 0, vx: 0, x: 80 + rnd(480), thr: 0, over: false, ac: 0 };
    clearInterval(timer); timer = setInterval(tick, 60);
    m.say("第 " + (lv + 1) + " / 3 關：" + S.nm + "（g = " + S.g + " m/s²）。↑↓ 調推力，Space 關引擎，←→ 側推。軟著陸：落地速度 ≤ 2.5 m/s 並停在綠色平台。", "info");
  }
  function ctl(k) {
    if (!S || S.over) return;
    if (k === "U" && S.thr < 10) S.thr++; if (k === "D" && S.thr > 0) S.thr--; if (k === "O") S.thr = 0;
    if (k === "L" && S.fuel > 0) { S.vx -= .5; S.fuel -= .3; } if (k === "R" && S.fuel > 0) { S.vx += .5; S.fuel -= .3; }
  }
  function tick() {
    if (S.over) return;
    if (S.fuel <= 0) { S.fuel = 0; S.thr = 0; }
    S.ac = S.thr / 10 * S.tmax - S.g;           // 淨加速度 = 引擎向上的加速度 − 重力加速度
    S.vy += S.ac * .1; S.alt += S.vy * .1; S.x = clamp(S.x + S.vx * 3, 20, 620);
    S.fuel -= S.thr / 10 * .25; if (S.fuel < 0) S.fuel = 0;
    if (S.alt <= 0) { S.alt = 0; S.over = true; clearInterval(timer); landed(); }
    draw();
  }
  function landed() {
    var sp = Math.abs(S.vy), onpad = Math.abs(S.x - padx) <= 35;
    var ok = sp <= 2.5 && Math.abs(S.vx) <= 2 && onpad;
    if (ok) { wins++; m.say("軟著陸成功！落地速度 " + sp.toFixed(1) + " m/s。", "ok"); }
    else if (!onpad) m.say("沒有降落在平台上！", "bad"); else m.say("墜毀！落地速度 " + sp.toFixed(1) + " m/s（上限 2.5）。自由落體：v² = 2gh，g 越大撞得越快。", "bad");
    var nb = lv < 2 ? btn("下一關", function () { lv++; nxt.remove(); start(); }) : h("div", { class: "big" }, "全部結束：軟著陸 " + wins + " / 3");
    var nxt = h("div", { class: "row c" }, nb); root.append(nxt);
  }
  function draw() {
    g.fillStyle = "#0b1026"; g.fillRect(0, 0, W, Hh);
    g.fillStyle = "#fff"; for (var i = 0; i < 40; i++) g.fillRect((i * 97) % W, (i * 53) % 380, 1.5, 1.5);
    g.fillStyle = "#6b7280"; g.fillRect(0, GY, W, Hh - GY); g.fillStyle = "#22c55e"; g.fillRect(padx - 35, GY, 70, 6);
    var y = GY - S.alt * 350 / ALT0, x = S.x;
    g.strokeStyle = "#e5e7eb"; g.lineWidth = 2; g.strokeRect(x - 8, y - 16, 16, 12); g.beginPath(); g.moveTo(x - 8, y - 4); g.lineTo(x - 13, y); g.moveTo(x + 8, y - 4); g.lineTo(x + 13, y); g.stroke();
    if (S.thr > 0 && !S.over) { g.fillStyle = "#f97316"; g.beginPath(); g.moveTo(x - 5, y - 4); g.lineTo(x + 5, y - 4); g.lineTo(x, y - 4 + S.thr * 3 + 6); g.fill(); }
    hud.textContent = "高度 " + S.alt.toFixed(0) + " m　下降速度 " + (-S.vy).toFixed(1) + " m/s　側向 " + S.vx.toFixed(1) + "　推力 " + S.thr + "/10　淨加速度 " + S.ac.toFixed(2) + " m/s²（+向上）　燃料 " + S.fuel.toFixed(0);
  }
  window.addEventListener("keydown", function (e) { var k = { ArrowUp: "U", ArrowDown: "D", ArrowLeft: "L", ArrowRight: "R", " ": "O" }[e.key]; if (k) ctl(k); });
  root.append(m.el, hud, cv.c, h("div", { class: "row c" }, btn("推力 +", function () { ctl("U"); }), btn("推力 −", function () { ctl("D"); }), btn("關引擎", function () { ctl("O"); }, "alt"), btn("◀ 側推", function () { ctl("L"); }, "alt"), btn("側推 ▶", function () { ctl("R"); }, "alt")),
    h("p", { class: "link" }, "重力讓登月艇每秒都「越掉越快」（加速度）。月球 g = 1.62 m/s²，地球 g = 9.8 m/s²。引擎提供向上的加速度，淨加速度 = 引擎 − g。"));
  start();
});

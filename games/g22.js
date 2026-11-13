// 22 逆風行舟：逆風行舟的原理
NMNS.register(22, function (root) {
  captureArrows();
  var W = 640, Hh = 440, cv = makeCanvas(W, Hh), g = cv.g, m = msgBar(), hud = h("div", { class: "row" });
  var lv = 0, bx, by, x, y, hd, tacks, side, t0, tot = 0, timer = 0, running = false, trail = [];
  function spd(a) { return a < 35 ? 0 : .25 + .75 * Math.sqrt(Math.sin((a - 35) * Math.PI / 145)); }
  function setup() {
    bx = 100 + rnd(440); by = 60; x = 320; y = 420; hd = 0; tacks = 0; side = 0; t0 = performance.now(); trail = []; running = true;
    m.say("第 " + (lv + 1) + " / 3 個浮標：風從上方吹來。用 ◀ ▶（或方向鍵）轉向，之字形前進。", "info");
    clearInterval(timer); timer = setInterval(tick, 60);
  }
  function turn(d) { if (!running) return; hd += d * 15; if (hd > 180) hd -= 360; if (hd <= -180) hd += 360; if (Math.sign(hd) && Math.abs(hd) >= 35) { var s = Math.sign(hd); if (side && s !== side) tacks++; side = s; } }
  function tick() {
    if (!running) return;
    var a = Math.abs(hd), v = spd(a), r = hd * Math.PI / 180;
    trail.push([x, y]); x = clamp(x + 6 * v * Math.sin(r), 15, 625); y = clamp(y - 6 * v * Math.cos(r), 95, 440);
    var tm = (performance.now() - t0) / 1000;
    hud.textContent = "第 " + (lv + 1) + "/3 個浮標　時間 " + tm.toFixed(0) + " 秒　轉向次數(tack) " + tacks + "　航向 " + Math.round(hd) + "°　與風夾角 " + Math.round(a) + "°　" + (a < 35 ? "⚠ 頂風卡住了！" : "船速 " + Math.round(v * 100) + "%　逆風前進 " + Math.round(v * Math.cos(r) * 100) + "%");
    draw();
    if ((y <= by + 40 && Math.abs(x - bx) < 24) || (y <= 96 && Math.abs(x - bx) < 40)) {
      running = false; clearInterval(timer); tot += tm;
      if (lv < 2) { m.say("到達浮標！用了 " + tm.toFixed(0) + " 秒、轉向 " + tacks + " 次。", "ok"); lv++; setTimeout(setup, 1200); }
      else m.say("三個浮標完成！總時間 " + tot.toFixed(0) + " 秒。接近風向 45° 角再轉向，就是逆風行舟的訣竅。按「重新開始」再玩。", "ok");
    }
  }
  function draw() {
    g.fillStyle = "#bfe3f6"; g.fillRect(0, 0, W, Hh);
    g.strokeStyle = "#5b8db8"; g.fillStyle = "#5b8db8"; g.lineWidth = 2;
    for (var i = 0; i < 5; i++) { var ax = 80 + i * 120; g.beginPath(); g.moveTo(ax, 20); g.lineTo(ax, 70); g.stroke(); g.beginPath(); g.moveTo(ax - 6, 62); g.lineTo(ax, 72); g.lineTo(ax + 6, 62); g.fill(); }
    g.font = "13px sans-serif"; g.fillStyle = "#1e3a5f"; g.fillText("風 ↓", 20, 20);
    g.fillStyle = "#ef4444"; g.beginPath(); g.arc(bx, by, 9, 0, 7); g.fill(); g.fillText("浮標", bx - 14, by - 14);
    g.strokeStyle = "rgba(30,90,140,.5)"; g.lineWidth = 2; g.beginPath(); trail.forEach(function (p, i) { i ? g.lineTo(p[0], p[1]) : g.moveTo(p[0], p[1]); }); g.stroke();
    var r = hd * Math.PI / 180, dx = Math.sin(r), dy = -Math.cos(r);
    g.strokeStyle = "#111"; g.lineWidth = 4; g.beginPath(); g.moveTo(x - 9 * dx, y - 9 * dy); g.lineTo(x + 12 * dx, y + 12 * dy); g.stroke();
    g.strokeStyle = "#fff"; g.lineWidth = 3; g.beginPath(); g.moveTo(x - 6 * dy, y + 6 * dx); g.lineTo(x + 6 * dy, y - 6 * dx); g.stroke();
    // 禁區
    g.strokeStyle = "rgba(220,38,38,.35)"; g.setLineDash([4, 4]); g.lineWidth = 1;
    [-35, 35].forEach(function (a) { var q = a * Math.PI / 180; g.beginPath(); g.moveTo(x, y); g.lineTo(x + 70 * Math.sin(q), y - 70 * Math.cos(q)); g.stroke(); }); g.setLineDash([]);
  }
  window.addEventListener("keydown", function (e) { if (e.key === "ArrowLeft") turn(-1); if (e.key === "ArrowRight") turn(1); });
  root.append(m.el, hud, cv.c, h("div", { class: "row c" }, btn("◀ 左轉 15°", function () { turn(-1); }), btn("右轉 15° ▶", function () { turn(1); })),
    h("p", { class: "link" }, "船不能直接頂著風走：和風向夾角小於 35°（紅色虛線內）帆就鼓不起來。風吹在帆上的力分成兩份，船底的龍骨擋住側向的力，只留向前的力，所以斜著走可以逐步前進。"));
  setup();
});

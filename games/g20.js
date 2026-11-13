// 20 海軍上將：向量、水流與航行等概念
NMNS.register(20, function (root) {
  var W = 640, Hh = 400, U = 28, cv = makeCanvas(W, Hh), g = cv.g, m = msgBar();
  var bear = h("input", { type: "range", min: 0, max: 359, value: 90 }), spd = h("input", { type: "range", min: 0, max: 40, value: 20 });
  var bl = h("span", { class: "pill" }), sl = h("span", { class: "pill" });
  var ship, port, cur, turns, over, trail, MAXT = 14;
  function newGame() {
    ship = [50, 320 + rnd(50)]; port = [560, 40 + rnd(60)]; trail = [ship.slice()]; turns = 0; over = false;
    cur = [0, 1, 2].map(function () { var a = rnd(360) * Math.PI / 180, mg = 0.5 + Math.random() * 1.8; return [Math.cos(a) * mg, Math.sin(a) * mg]; });
    draw(); upd(); m.say("上將，從左下角開到右上方港口！每個水域有不同水流。每回合選航向與速度，淺色箭頭可預覽。共 " + MAXT + " 回合。", "info");
  }
  function zone(x) { return x < 213 ? 0 : x < 426 ? 1 : 2; }
  function vec() { var a = +bear.value * Math.PI / 180, s = +spd.value / 10; return [Math.sin(a) * s, -Math.cos(a) * s]; }
  function arrow(x, y, dx, dy, col, w) {
    g.strokeStyle = col; g.fillStyle = col; g.lineWidth = w || 3; g.beginPath(); g.moveTo(x, y); g.lineTo(x + dx, y + dy); g.stroke();
    var a = Math.atan2(dy, dx); if (Math.hypot(dx, dy) < 4) return;
    g.beginPath(); g.moveTo(x + dx, y + dy); g.lineTo(x + dx - 9 * Math.cos(a - .4), y + dy - 9 * Math.sin(a - .4)); g.lineTo(x + dx - 9 * Math.cos(a + .4), y + dy - 9 * Math.sin(a + .4)); g.fill();
  }
  function draw() {
    g.fillStyle = "#cfe9fb"; g.fillRect(0, 0, W, Hh);
    for (var z = 0; z < 3; z++) {
      g.fillStyle = z === 1 ? "#bfe0f7" : "#d8eefc"; g.fillRect(z * 213, 0, 213, Hh);
      for (var i = 0; i < 4; i++) for (var j = 0; j < 4; j++) arrow(z * 213 + 35 + i * 48, 60 + j * 90, cur[z][0] * U * .9, cur[z][1] * U * .9, "rgba(0,128,0,.35)", 2);
      g.fillStyle = "#14532d"; g.font = "12px sans-serif"; g.fillText("水流 " + Math.hypot(cur[z][0], cur[z][1]).toFixed(1) + "，往" + dirName(cur[z]), z * 213 + 8, 392);
    }
    g.fillStyle = "#a16207"; g.fillRect(port[0] - 4, port[1] - 4, 44, 8); g.font = "22px sans-serif"; g.fillText("⚓", port[0] + 6, port[1] - 8);
    g.strokeStyle = "#999"; g.setLineDash([4, 4]); g.beginPath(); trail.forEach(function (p, i) { i ? g.lineTo(p[0], p[1]) : g.moveTo(p[0], p[1]); }); g.stroke(); g.setLineDash([]);
    if (!over) {
      var v = vec(), c = cur[zone(ship[0])];
      arrow(ship[0], ship[1], v[0] * U, v[1] * U, "#2563eb"); arrow(ship[0], ship[1], c[0] * U, c[1] * U, "#16a34a");
      arrow(ship[0], ship[1], (v[0] + c[0]) * U, (v[1] + c[1]) * U, "#dc2626", 4);
    }
    g.font = "26px sans-serif"; g.fillText("🚢", ship[0] - 14, ship[1] + 8);
  }
  function dirName(v) { var a = Math.atan2(-v[1], v[0]) * 180 / Math.PI, n = ["東", "東北", "北", "西北", "西", "西南", "南", "東南"]; return n[Math.round(((a + 360) % 360) / 45) % 8]; }
  function upd() { bl.textContent = "航向 " + bear.value + "°（0=北 90=東）"; sl.textContent = "船速 " + (+spd.value / 10).toFixed(1); draw(); }
  function sail() {
    if (over) return; var v = vec(), c = cur[zone(ship[0])];
    ship = [clamp(ship[0] + (v[0] + c[0]) * U, 10, W - 10), clamp(ship[1] + (v[1] + c[1]) * U, 15, Hh - 15)]; trail.push(ship.slice()); turns++;
    var d = Math.hypot(ship[0] - (port[0] + 18), ship[1] - port[1]);
    if (d < 32) { over = true; m.say("抵達港口！只用了 " + turns + " 回合，優秀的上將！", "ok"); }
    else if (turns >= MAXT) { over = true; m.say("回合用完，還差 " + d.toFixed(0) + " 像素到港口。再試一次！", "bad"); }
    else m.say("第 " + turns + " 回合：實際位移 = 船速向量 + 水流向量。距港口 " + d.toFixed(0) + "。", "info");
    upd();
  }
  [bear, spd].forEach(function (e) { e.addEventListener("input", upd); });
  root.append(h("div", { class: "row" }, "航向", bear, bl), h("div", { class: "row" }, "船速", spd, sl), h("div", { class: "row" }, btn("起航（下一回合）", sail), btn("重新出發", newGame, "alt")), m.el, cv.c,
    h("p", { class: "link" }, "🔵 藍箭頭：船自己的航行向量　🟢 綠箭頭：水流向量　🔴 紅箭頭：兩者相加＝這回合真正的移動。要抵銷水流，航向要朝水流的反方向偏一點。"));
  newGame();
});

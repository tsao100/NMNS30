// 07 非洲狩獵：由動物搜尋推理，認識直角座標系
NMNS.register(7, function (root) {
  var R = 10, C = 20, OFF = 20, SZ = OFF * 2 + C * (R * 2), cv = makeCanvas(SZ, SZ), g = cv.g;
  var m = msgBar(), pos = h("div", { class: "pill" }, "游標座標：—");
  var animals, shots, shotsLeft, misses, over;
  var ICON = ["🦁", "🐘", "🦒"], NAME = ["獅子", "大象", "長頸鹿"];
  function X(x) { return OFF + (x + R) * C; }
  function Y(y) { return OFF + (R - y) * C; }
  function draw() {
    g.fillStyle = "#fbf3d6"; g.fillRect(0, 0, SZ, SZ);
    g.strokeStyle = "#e3d6a0"; g.lineWidth = 1;
    for (var i = -R; i <= R; i++) {
      g.beginPath(); g.moveTo(X(i), Y(R)); g.lineTo(X(i), Y(-R)); g.stroke();
      g.beginPath(); g.moveTo(X(-R), Y(i)); g.lineTo(X(R), Y(i)); g.stroke();
    }
    g.strokeStyle = "#7c5a14"; g.lineWidth = 2;
    g.beginPath(); g.moveTo(X(-R), Y(0)); g.lineTo(X(R), Y(0)); g.moveTo(X(0), Y(R)); g.lineTo(X(0), Y(-R)); g.stroke();
    g.fillStyle = "#5b4510"; g.font = "11px sans-serif"; g.textAlign = "center";
    for (var k = -R; k <= R; k += 2) { if (k) { g.fillText(k, X(k), Y(0) + 13); g.textAlign = "right"; g.fillText(k, X(0) - 4, Y(k) + 4); g.textAlign = "center"; } }
    g.font = "bold 13px sans-serif"; g.fillText("x", X(R) + 14, Y(0) + 4); g.fillText("y", X(0) + 10, Y(R) - 6);
    misses.forEach(function (s, i) { g.fillStyle = "#b42318"; g.font = "bold 14px sans-serif"; g.fillText("✕", X(s[0]), Y(s[1]) + 5); g.font = "10px sans-serif"; g.fillText(i + 1, X(s[0]) + 8, Y(s[1]) - 6); });
    g.font = "20px sans-serif"; g.textBaseline = "middle";
    animals.forEach(function (a, i) { if (a.hit) g.fillText(ICON[i], X(a.x), Y(a.y)); });
    g.textBaseline = "alphabetic";
  }
  function dirName(dx, dy) {
    var ang = Math.atan2(dy, dx) * 180 / Math.PI, names = ["東", "東北", "北", "西北", "西", "西南", "南", "東南"];
    return names[Math.round(((ang + 360) % 360) / 45) % 8];
  }
  function newGame() {
    animals = []; misses = []; shots = 0; shotsLeft = 15; over = false;
    while (animals.length < 3) {
      var x = rnd(21) - 10, y = rnd(21) - 10;
      if (!animals.some(function (a) { return a.x === x && a.y === y; }) && (x || y)) animals.push({ x: x, y: y, hit: false });
    }
    draw(); m.say("草原上藏著 🦁 獅子、🐘 大象、🦒 長頸鹿。點一下格子交點開槍（要打中整數座標）。剩 15 發。", "info");
  }
  function shoot(x, y) {
    if (over) return;
    var hitIdx = -1;
    animals.forEach(function (a, i) { if (!a.hit && a.x === x && a.y === y) hitIdx = i; });
    shotsLeft--;
    if (hitIdx >= 0) {
      animals[hitIdx].hit = true;
      var left = animals.filter(function (a) { return !a.hit; }).length;
      if (!left) { over = true; draw(); m.say("太棒了！3 隻動物都找到了，只用了 " + (15 - shotsLeft) + " 發！", "ok"); return; }
      m.say("命中 " + NAME[hitIdx] + " (" + x + ", " + y + ")！還剩 " + left + " 隻，子彈 " + shotsLeft + " 發。", "ok");
    } else {
      misses.push([x, y]);
      var best = null, bd = 1e9;
      animals.forEach(function (a) { if (!a.hit) { var d = Math.hypot(a.x - x, a.y - y); if (d < bd) { bd = d; best = a; } } });
      var far = bd <= 2 ? "非常近" : bd <= 5 ? "不遠" : bd <= 9 ? "有點遠" : "很遠";
      m.say("(" + x + ", " + y + ") 沒打中。最近的動物在你的「" + dirName(best.x - x, best.y - y) + "」方，距離" + far + "。子彈剩 " + shotsLeft + " 發。", "bad");
    }
    if (shotsLeft <= 0) {
      over = true; animals.forEach(function (a) { a.hit = true; }); draw();
      m.say("子彈用完了！動物的位置如圖。按「重新開始」再玩。", "bad"); return;
    }
    draw();
  }
  function grid(ev) { var p = canvasPos(cv.c, ev); return [clamp(Math.round((p.x - OFF) / C) - R, -R, R), clamp(R - Math.round((p.y - OFF) / C), -R, R)]; }
  cv.c.addEventListener("click", function (e) { var q = grid(e); shoot(q[0], q[1]); });
  cv.c.addEventListener("mousemove", function (e) { var q = grid(e); pos.textContent = "游標座標：(" + q[0] + ", " + q[1] + ")"; });
  var xi = h("input", { type: "number", min: -10, max: 10, value: 0, "aria-label": "x" }), yi = h("input", { type: "number", min: -10, max: 10, value: 0, "aria-label": "y" });
  root.append(m.el, h("div", { class: "row" }, pos, "或輸入：x", xi, "y", yi, btn("開槍", function () {
    var x = Math.round(+xi.value), y = Math.round(+yi.value);
    if (Math.abs(x) > R || Math.abs(y) > R) { m.say("座標要在 −10 到 10 之間。", "bad"); return; } shoot(x, y);
  })), cv.c, h("p", { class: "link" }, "直角座標 (x, y)：x 是左右（右為正），y 是上下（上為正）。看提示的方向和距離縮小範圍。"));
  newGame();
});

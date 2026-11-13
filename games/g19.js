// 19 立體連珠：立體空間座標與平面關係（4×4×4 立體四子棋）
NMNS.register(19, function (root) {
  var m = msgBar(), cube, turn, over, winCells = {}, lines = [], ai = true, last = null;
  var layers = h("div", { class: "row c", style: "align-items:flex-start;gap:14px" });
  var mode = h("select", {}, h("option", { value: "ai" }, "對電腦"), h("option", { value: "two" }, "雙人輪流"));
  // 建立 76 條勝利線
  var dirs = [];
  for (var dx = -1; dx <= 1; dx++) for (var dy = -1; dy <= 1; dy++) for (var dz = -1; dz <= 1; dz++) {
    if ((dx || dy || dz) && (dx > 0 || (dx === 0 && (dy > 0 || (dy === 0 && dz > 0))))) dirs.push([dx, dy, dz]);
  }
  for (var x = 0; x < 4; x++) for (var y = 0; y < 4; y++) for (var z = 0; z < 4; z++) dirs.forEach(function (d) {
    var ex = x + 3 * d[0], ey = y + 3 * d[1], ez = z + 3 * d[2];
    if (ex < 0 || ex > 3 || ey < 0 || ey > 3 || ez < 0 || ez > 3) return;
    var l = []; for (var k = 0; k < 4; k++) l.push([x + k * d[0], y + k * d[1], z + k * d[2]]); lines.push(l);
  });
  function at(p) { return cube[p[2]][p[1]][p[0]]; }
  function dropZ(x, y) { for (var z = 0; z < 4; z++) if (!cube[z][y][x]) return z; return -1; }
  function winLine(p) { for (var i = 0; i < lines.length; i++) { var l = lines[i]; if (l.every(function (c) { return at(c) === p; })) return l; } return null; }
  function render() {
    layers.innerHTML = "";
    for (var z = 3; z >= 0; z--) {
      var gr = h("div", { class: "cellgrid", style: "grid-template-columns:repeat(4,44px);gap:4px" });
      for (var y = 0; y < 4; y++) for (var x = 0; x < 4; x++) (function (x, y, z) {
        var v = cube[z][y][x], key = x + "," + y + "," + z, isLast = last && last[0] === x && last[1] === y && last[2] === z;
        gr.append(h("button", { class: "cell", type: "button", "aria-label": "x" + (x + 1) + " y" + (y + 1) + " z" + (z + 1), style: "min-height:44px;border-radius:50%;font-size:1.2rem;color:#fff;background:" + (v === "X" ? "#2563eb" : v === "O" ? "#dc2626" : "var(--bg)") + (winCells[key] ? ";outline:4px solid #fbbf24" : isLast ? ";outline:2px solid #111" : ""), onclick: function () { play(x, y); } }, v === "X" ? "●" : v === "O" ? "●" : ""));
      })(x, y, z);
      layers.append(h("div", { style: "text-align:center" }, h("div", { class: "pill", style: "margin-bottom:4px" }, "第 " + (z + 1) + " 層" + (z === 0 ? "（最底）" : z === 3 ? "（最頂）" : "")), gr));
    }
  }
  function finish(p, l) { over = true; l.forEach(function (c) { winCells[c.join(",")] = 1; }); render(); m.say((p === "X" ? "藍色" : "紅色") + "連成四子，獲勝！", p === "X" ? "ok" : "bad"); }
  function place(x, y, p) {
    var z = dropZ(x, y); if (z < 0) return false; cube[z][y][x] = p; last = [x, y, z];
    var l = winLine(p); if (l) { finish(p, l); return true; }
    if (cube.every(function (pl) { return pl.every(function (r) { return r.every(Boolean); }); })) { over = true; render(); m.say("棋盤滿了，平手。", "info"); return true; }
    return true;
  }
  function pegs() { var a = []; for (var y = 0; y < 4; y++) for (var x = 0; x < 4; x++) if (dropZ(x, y) >= 0) a.push([x, y]); return a; }
  function wouldWin(x, y, p) { var z = dropZ(x, y); cube[z][y][x] = p; var w = !!winLine(p); cube[z][y][x] = null; return w; }
  function aiPlay() {
    var ps = pegs(), i, best = null, bs = -1e9;
    for (i = 0; i < ps.length; i++) if (wouldWin(ps[i][0], ps[i][1], "O")) return place(ps[i][0], ps[i][1], "O");
    for (i = 0; i < ps.length; i++) if (wouldWin(ps[i][0], ps[i][1], "X")) return place(ps[i][0], ps[i][1], "O");
    ps.forEach(function (p) {
      var z = dropZ(p[0], p[1]), s = Math.random();
      cube[z][p[1]][p[0]] = "O";
      if (z < 3 && wouldWin(p[0], p[1], "X")) s -= 50;
      cube[z][p[1]][p[0]] = null;
      lines.forEach(function (l) {
        if (!l.some(function (c) { return c[0] === p[0] && c[1] === p[1] && c[2] === z; })) return;
        var o = 0, xx = 0; l.forEach(function (c) { var v = at(c); if (v === "O") o++; else if (v === "X") xx++; });
        if (!xx) s += [1, 3, 10, 0][o]; if (!o) s += [0.5, 2, 6, 0][xx];
      });
      if (s > bs) { bs = s; best = p; }
    });
    return place(best[0], best[1], "O");
  }
  function play(x, y) {
    if (over) return; var p = turn;
    if (dropZ(x, y) < 0) { m.say("這根柱子已經滿了。", "bad"); return; }
    if (place(x, y, p)) { if (over) return; }
    if (mode.value === "ai") { aiPlay(); if (!over) { render(); m.say("輪到你（藍色）。", "info"); } return; }
    turn = turn === "X" ? "O" : "X"; render(); m.say("輪到" + (turn === "X" ? "藍色" : "紅色") + "。", "info");
  }
  function newGame() {
    cube = []; for (var z = 0; z < 4; z++) { cube.push([]); for (var y = 0; y < 4; y++) cube[z].push([null, null, null, null]); }
    turn = "X"; over = false; winCells = {}; last = null; render();
    m.say("你是藍色。點任一層的格子＝選那根柱子的 (x, y)，棋子會掉到最底下的空位。", "info");
  }
  mode.addEventListener("change", newGame);
  root.append(h("div", { class: "row" }, mode, btn("新的一局", newGame, "alt")), m.el, layers,
    h("p", { class: "link" }, "立體座標 (x, y, z)：每一層是一個平面（z 固定）。四子可以連在同一平面、垂直穿過各層，或斜著穿過立方體，一共 " + lines.length + " 條線。"));
  newGame();
});

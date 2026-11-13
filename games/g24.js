// 24 雷射迷宮：雷射槍及鏡子反射，學習光的反射原理
NMNS.register(24, function (root) {
  var C = 10, R = 8, S = 56, cv = makeCanvas(C * S, R * S), g = cv.g, m = msgBar();
  var lvl = 0, TOTAL = 5, grid, laser, target, maxM, walls, won = false, ml = h("span", { class: "pill" });
  var DIRS = [[1, 0], [0, -1], [-1, 0], [0, 1]]; // 東 北 西 南
  function refl(d, t) { return t === "/" ? [-d[1], -d[0]] : [d[1], d[0]]; }
  function same(a, b) { return a[0] === b[0] && a[1] === b[1]; }

  function gen(turns) {
    for (var attempt = 0; attempt < 400; attempt++) {
      var r = 1 + rnd(R - 2), pos = [0, r], d = [1, 0], visited = {}, need = 0, ok = true;
      visited["0," + r] = 1;
      for (var t = 0; t <= turns && ok; t++) {
        var L = 2 + rnd(3), last = t === turns;
        for (var k = 0; k < L && ok; k++) { pos = [pos[0] + d[0], pos[1] + d[1]]; if (pos[0] < 0 || pos[0] >= C || pos[1] < 0 || pos[1] >= R || visited[pos.join(",")]) ok = false; else visited[pos.join(",")] = 1; }
        if (!ok) break;
        if (last) { return { laser: r, target: pos.slice(), need: need, visited: visited }; }
        var opts = shuffle(["/", "\\"]), pick1 = null;
        opts.forEach(function (tp) { if (pick1) return; var nd = refl(d, tp), np = [pos[0] + nd[0], pos[1] + nd[1]]; if (np[0] >= 0 && np[0] < C && np[1] >= 0 && np[1] < R && !visited[np.join(",")]) pick1 = { t: tp, nd: nd }; });
        if (!pick1) { ok = false; break; } d = pick1.nd; need++;
      }
    }
    return null;
  }
  function trace() {
    var d = [1, 0], pos = [0, laser], path = [[-0.5, laser]], hit = false, n = 0;
    while (n++ < 300) {
      if (pos[0] < 0 || pos[0] >= C || pos[1] < 0 || pos[1] >= R) { path.push([pos[0] - d[0] / 2, pos[1] - d[1] / 2]); break; }
      if (walls[pos.join(",")]) { path.push([pos[0] - d[0] / 2, pos[1] - d[1] / 2]); break; }
      path.push([pos[0], pos[1]]);
      if (same(pos, target)) { hit = true; break; }
      var t = grid[pos.join(",")]; if (t) d = refl(d, t);
      pos = [pos[0] + d[0], pos[1] + d[1]];
    }
    return { path: path, hit: hit };
  }
  function used() { return Object.keys(grid).length; }
  function newLevel() {
    var lv = gen(2 + Math.min(lvl, 3)); while (!lv) lv = gen(2);
    laser = lv.laser; target = lv.target; grid = {}; walls = {}; won = false;
    maxM = lv.need + 1;
    var cnt = 5 + lvl * 2, tries = 0;
    while (cnt > 0 && tries++ < 200) { var x = rnd(C), y = rnd(R), k = x + "," + y; if (lv.visited[k] || (x === 0 && y === laser)) continue; walls[k] = 1; cnt--; }
    m.say("第 " + (lvl + 1) + " / " + TOTAL + " 關：點格子放鏡子（再點換方向、再點拿掉），讓雷射打中紅色目標。可用鏡子 " + maxM + " 面。", "info"); draw();
  }
  function draw() {
    g.fillStyle = "#0f172a"; g.fillRect(0, 0, C * S, R * S);
    g.strokeStyle = "#1e293b"; g.lineWidth = 1;
    for (var i = 0; i <= C; i++) { g.beginPath(); g.moveTo(i * S, 0); g.lineTo(i * S, R * S); g.stroke(); }
    for (var j = 0; j <= R; j++) { g.beginPath(); g.moveTo(0, j * S); g.lineTo(C * S, j * S); g.stroke(); }
    Object.keys(walls).forEach(function (k) { var p = k.split(",").map(Number); g.fillStyle = "#475569"; g.fillRect(p[0] * S + 2, p[1] * S + 2, S - 4, S - 4); });
    var tr = trace();
    g.strokeStyle = "#22d3ee"; g.shadowColor = "#22d3ee"; g.shadowBlur = 8; g.lineWidth = 3; g.beginPath();
    tr.path.forEach(function (p, i) { var X = (p[0] + .5) * S, Y = (p[1] + .5) * S; i ? g.lineTo(X, Y) : g.moveTo(X, Y); }); g.stroke(); g.shadowBlur = 0;
    g.fillStyle = tr.hit ? "#22c55e" : "#ef4444"; g.beginPath(); g.arc((target[0] + .5) * S, (target[1] + .5) * S, 16, 0, 7); g.fill();
    g.fillStyle = "#fbbf24"; g.fillRect(0, laser * S + S / 2 - 10, 12, 20); g.font = "11px sans-serif"; g.fillStyle = "#fff"; g.fillText("雷射", 14, laser * S + 14);
    Object.keys(grid).forEach(function (k) { var p = k.split(","), cx = (+p[0] + .5) * S, cy = (+p[1] + .5) * S, t = grid[k], a = t === "/" ? -1 : 1; g.strokeStyle = "#e2e8f0"; g.lineWidth = 6; g.beginPath(); g.moveTo(cx - 20, cy + 20 * a); g.lineTo(cx + 20, cy - 20 * a); g.stroke(); });
    ml.textContent = "鏡子 " + used() + " / " + maxM;
    if (tr.hit && !won) { won = true; m.say("命中目標！入射角 = 反射角。" + (lvl + 1 < TOTAL ? "按「下一關」。" : "全部通關！"), "ok"); if (lvl + 1 < TOTAL) nb.disabled = false; }
  }
  cv.c.addEventListener("click", function (e) {
    if (won) return; var p = canvasPos(cv.c, e), x = Math.floor(p.x / S), y = Math.floor(p.y / S), k = x + "," + y;
    if (walls[k] || same([x, y], target) || (x === 0 && y === laser)) return;
    var cur = grid[k];
    if (!cur) { if (used() >= maxM) { m.say("鏡子用完了，先拿掉一面。", "bad"); return; } grid[k] = "/"; } else if (cur === "/") grid[k] = "\\"; else delete grid[k];
    draw();
  });
  var nb = btn("下一關", function () { lvl++; nb.disabled = true; newLevel(); }); nb.disabled = true;
  root.append(m.el, h("div", { class: "row" }, ml, btn("清除鏡子", function () { if (!won) { grid = {}; draw(); } }, "alt"), btn("換一張新地圖", function () { nb.disabled = true; newLevel(); }, "alt"), nb), cv.c,
    h("p", { class: "link" }, "光的反射定律：入射角等於反射角。鏡子 ╱ 和 ╲ 會把光轉 90°。灰色方塊會擋住雷射。"));
  newLevel();
});

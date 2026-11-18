// 06 頭腦體操：比較多少、長短、異同及迷宮測驗
NMNS.register(6, function (root) {
  captureArrows();
  var m = msgBar(), area = h("div"), round = 0, score = 0, TOTAL = 10, mazeKey = null;
  var FACES = [["🍎", "🍅"], ["🐶", "🐱"], ["🌞", "🌕"], ["⭐", "🌟"], ["🍊", "🏀"], ["😀", "😃"]];

  function dotsCanvas(n) {
    var cv = makeCanvas(220, 160), g = cv.g;
    g.fillStyle = "#fff8e7"; g.fillRect(0, 0, 220, 160); g.fillStyle = "#c2410c";
    var used = [];
    while (used.length < n) {
      var p = [14 + rnd(10) * 19.2, 14 + rnd(7) * 19.5], ok = !used.some(function (q) { return q[0] === p[0] && q[1] === p[1]; });
      if (ok) used.push(p);
    }
    used.forEach(function (p) { g.beginPath(); g.arc(p[0], p[1], 6, 0, 7); g.fill(); });
    return cv.c;
  }
  var stages = [
    { title: "比多少：哪一邊的圓點比較多？", make: function (done) {
      var a = 8 + rnd(25), b = a + (rnd(2) ? 1 : -1) * (1 + rnd(4)), left = a > b;
      return h("div", {}, h("div", { class: "row c" }, dotsCanvas(a), dotsCanvas(b)),
        h("div", { class: "row c" }, btn("左邊多", function () { done(left); }), btn("右邊多", function () { done(!left); })));
    } },
    { title: "比長短：哪一條線比較長？", make: function (done) {
      var cv = makeCanvas(420, 140), g = cv.g, a = 150 + rnd(200), b = a + (rnd(2) ? 1 : -1) * (6 + rnd(25)), top = a > b;
      g.fillStyle = "#fff"; g.fillRect(0, 0, 420, 140); g.fillStyle = "#1d4e89";
      g.fillRect(20 + rnd(20), 30, a, 14); g.fillRect(20 + rnd(20), 90, b, 14);
      return h("div", {}, h("div", { class: "row c" }, cv.c), h("div", { class: "row c" }, btn("上面那條長", function () { done(top); }), btn("下面那條長", function () { done(!top); })));
    } },
    { title: "找異同：找出和別人不一樣的那一個", make: function (done) {
      var pr = pick(FACES), N = 5, odd = rnd(N * N), grid = h("div", { class: "cellgrid", style: "grid-template-columns:repeat(5,52px);justify-content:center" });
      for (var i = 0; i < N * N; i++) (function (i) { grid.append(h("button", { class: "cell", type: "button", style: "font-size:1.6rem;min-height:52px", onclick: function () { done(i === odd); } }, i === odd ? pr[1] : pr[0])); })(i);
      return grid;
    } }
  ];
  function maze() {
    var W = 21, cell = 20, grid = [], i, j;
    for (i = 0; i < W; i++) { grid.push([]); for (j = 0; j < W; j++) grid[i].push(1); }
    (function carve(x, y) {
      grid[y][x] = 0;
      shuffle([[1, 0], [-1, 0], [0, 1], [0, -1]]).forEach(function (d) {
        var nx = x + d[0] * 2, ny = y + d[1] * 2;
        if (nx > 0 && ny > 0 && nx < W - 1 && ny < W - 1 && grid[ny][nx]) { grid[y + d[1]][x + d[0]] = 0; carve(nx, ny); }
      });
    })(1, 1);
    var p = [1, 1], goal = [W - 2, W - 2], steps = 0, cv = makeCanvas(W * cell, W * cell), g = cv.g, finished = false;
    function draw() {
      for (var y = 0; y < W; y++) for (var x = 0; x < W; x++) { g.fillStyle = grid[y][x] ? "#374151" : "#fffdf5"; g.fillRect(x * cell, y * cell, cell, cell); }
      g.font = "16px sans-serif"; g.textAlign = "center"; g.textBaseline = "middle";
      g.fillText("🏁", goal[0] * cell + 10, goal[1] * cell + 11); g.fillText("🐭", p[0] * cell + 10, p[1] * cell + 11);
    }
    function mv(d) {
      if (finished) return;
      var nx = p[0] + d[0], ny = p[1] + d[1];
      if (grid[ny] && grid[ny][nx] === 0) { p = [nx, ny]; steps++; draw(); }
      if (p[0] === goal[0] && p[1] === goal[1]) { finished = true; score += 2; NMNS.finish(6, score); m.say("走出迷宮了！共 " + steps + " 步。總分 " + score + " / " + (TOTAL + 1) + "。按「重新開始」再玩。", "ok"); }
    }
    var map = { U: [0, -1], D: [0, 1], L: [-1, 0], R: [1, 0] };
    mazeKey = function (e) { var d = { ArrowUp: "U", ArrowDown: "D", ArrowLeft: "L", ArrowRight: "R" }[e.key]; if (d) mv(map[d]); };
    draw();
    return h("div", {}, h("div", { class: "row c" }, cv.c), dpad(function (d) { mv(map[d]); }));
  }
  window.addEventListener("keydown", function (e) { if (mazeKey) mazeKey(e); });
  function next() {
    area.innerHTML = ""; mazeKey = null;
    if (round >= TOTAL) { area.append(h("h3", {}, "第 4 關：迷宮"), h("p", {}, "用方向鍵（或下面的按鈕）帶小老鼠走到 🏁。"), maze()); m.say("前三關答對 " + score + " / " + TOTAL + " 題，最後挑戰迷宮！", "info"); return; }
    var st = stages[round < 3 ? 0 : round < 6 ? 1 : 2], idx = round + 1;
    m.say("第 " + idx + " / " + TOTAL + " 題　目前答對 " + score + " 題", "info");
    area.append(h("h3", {}, st.title), st.make(function (ok) {
      if (ok) score++;
      m.say(ok ? "答對了！" : "答錯了。", ok ? "ok" : "bad"); round++; setTimeout(next, 600);
    }));
  }
  root.append(m.el, area);
  next();
});

// 01 貓捉老鼠：辨認東西南北方向及判斷距離
NMNS.register(1, function (root) {
  captureArrows();
  var N = 10, S = 40;
  var DIR = { N: [0, -1, "北"], S: [0, 1, "南"], E: [1, 0, "東"], W: [-1, 0, "西"] };
  var cv = makeCanvas(N * S, N * S), g = cv.g;
  var m = msgBar();
  var area = h("div"), mode = 0;
  var cat, mouse, start, moves, caught, dirSel = "E", stepSel = 1;
  var qa = { n: 0, ok: 0, d: "E", dist: 3, pickD: null, pickN: null, done: false };

  function draw() {
    g.clearRect(0, 0, N * S, N * S);
    g.fillStyle = "#e8f1e4"; g.fillRect(0, 0, N * S, N * S);
    g.strokeStyle = "#b9c9b2"; g.lineWidth = 1;
    for (var i = 0; i <= N; i++) {
      g.beginPath(); g.moveTo(i * S, 0); g.lineTo(i * S, N * S); g.stroke();
      g.beginPath(); g.moveTo(0, i * S); g.lineTo(N * S, i * S); g.stroke();
    }
    g.fillStyle = "#14532d"; g.font = "bold 14px sans-serif"; g.textAlign = "center";
    g.fillText("北 ▲", N * S / 2, 14); g.fillText("南 ▼", N * S / 2, N * S - 4);
    g.save(); g.translate(12, N * S / 2); g.rotate(-Math.PI / 2); g.fillText("西 ◀", 0, 0); g.restore();
    g.save(); g.translate(N * S - 4, N * S / 2); g.rotate(Math.PI / 2); g.fillText("東 ▶", 0, 0); g.restore();
    g.font = "26px sans-serif"; g.textBaseline = "middle";
    g.fillText("🐭", mouse[0] * S + S / 2, mouse[1] * S + S / 2 + 2);
    g.fillText("🐱", cat[0] * S + S / 2, cat[1] * S + S / 2 + 2);
    g.textBaseline = "alphabetic";
  }
  function rel(a, b) { // b 在 a 的哪個方向
    var dx = b[0] - a[0], dy = b[1] - a[1], t = [];
    if (dx) t.push((dx > 0 ? "東" : "西") + " " + Math.abs(dx) + " 格");
    if (dy) t.push((dy > 0 ? "南" : "北") + " " + Math.abs(dy) + " 格");
    return t.length ? t.join("，") : "同一格";
  }

  // ---- 模式 1：捉老鼠 ----
  function newChase() {
    do { cat = [rnd(N), rnd(N)]; mouse = [rnd(N), rnd(N)]; } while (Math.abs(cat[0] - mouse[0]) + Math.abs(cat[1] - mouse[1]) < 5);
    start = cat.slice(); moves = 0; caught = false;
    draw(); info();
  }
  function info() {
    var best = Math.abs(start[0] - mouse[0]) + Math.abs(start[1] - mouse[1]);
    m.say(caught ? "抓到老鼠了！共走 " + moves + " 次指令。" : "老鼠在貓的：" + rel(cat, mouse) + "。已下 " + moves + " 次指令。", caught ? "ok" : "info");
  }
  function go(d, k) {
    if (caught) return;
    for (var i = 0; i < k; i++) {
      var nx = cat[0] + DIR[d][0], ny = cat[1] + DIR[d][1];
      if (nx < 0 || ny < 0 || nx >= N || ny >= N) break;
      cat = [nx, ny];
      if (cat[0] === mouse[0] && cat[1] === mouse[1]) { caught = true; break; }
    }
    moves++;
    if (!caught) { // 老鼠隨機逃一步
      var ds = shuffle(["N", "S", "E", "W"]);
      for (var j = 0; j < 4; j++) {
        var x = mouse[0] + DIR[ds[j]][0], y = mouse[1] + DIR[ds[j]][1];
        if (x >= 0 && y >= 0 && x < N && y < N && !(x === cat[0] && y === cat[1])) { mouse = [x, y]; break; }
      }
    }
    draw(); info();
  }
  function chaseUI() {
    area.innerHTML = "";
    var dirs = h("div", { class: "row" }), steps = h("div", { class: "row" });
    ["N", "S", "E", "W"].forEach(function (d) {
      var b = btn(DIR[d][2], function () { dirSel = d; refresh(); }, "choice");
      b.dataset.d = d; dirs.append(b);
    });
    [1, 2, 3, 4, 5].forEach(function (k) {
      var b = btn(k + " 格", function () { stepSel = k; refresh(); }, "choice");
      b.dataset.k = k; steps.append(b);
    });
    function refresh() {
      dirs.querySelectorAll("button").forEach(function (b) { b.classList.toggle("sel", b.dataset.d === dirSel); });
      steps.querySelectorAll("button").forEach(function (b) { b.classList.toggle("sel", +b.dataset.k === stepSel); });
    }
    area.append(h("p", {}, "選方向與格數，按「出發」。每次指令後老鼠會逃一步。也可用鍵盤方向鍵走一格。"),
      h("div", { class: "row" }, "方向：", dirs), h("div", { class: "row" }, "格數：", steps),
      h("div", { class: "row" }, btn("出發", function () { go(dirSel, stepSel); }), btn("新一局", newChase, "alt")));
    refresh(); newChase();
  }
  // ---- 模式 2：方向問答 ----
  function newQ() {
    qa.d = pick(["N", "S", "E", "W"]); qa.dist = 1 + rnd(7); qa.pickD = null; qa.pickN = null; qa.done = false;
    var cx, cy;
    do { cx = rnd(N); cy = rnd(N); mouse = [cx + DIR[qa.d][0] * qa.dist, cy + DIR[qa.d][1] * qa.dist]; } while (mouse[0] < 0 || mouse[1] < 0 || mouse[0] >= N || mouse[1] >= N);
    cat = [cx, cy]; draw();
  }
  function quizUI() {
    area.innerHTML = ""; qa.n = 0; qa.ok = 0;
    var qText = h("p", { class: "big" }), dirs = h("div", { class: "row" }), nums = h("div", { class: "row" });
    function show() { qText.textContent = "第 " + (qa.n + 1) + " 題 / 共 5 題：老鼠 🐭 在貓 🐱 的哪個方向？距離幾格？"; }
    function refresh() {
      dirs.querySelectorAll("button").forEach(function (b) { b.classList.toggle("sel", b.dataset.d === qa.pickD); });
      nums.querySelectorAll("button").forEach(function (b) { b.classList.toggle("sel", +b.dataset.k === qa.pickN); });
    }
    ["N", "S", "E", "W"].forEach(function (d) { var b = btn(DIR[d][2], function () { qa.pickD = d; refresh(); }, "choice"); b.dataset.d = d; dirs.append(b); });
    for (var k = 1; k <= 8; k++) (function (k) { var b = btn(String(k), function () { qa.pickN = k; refresh(); }, "choice"); b.dataset.k = k; nums.append(b); })(k);
    var ok = btn("確定", function () {
      if (qa.done) { if (qa.n >= 5) { quizUI(); return; } newQ(); show(); refresh(); ok.textContent = "確定"; qa.done = false; m.say("請作答。", "info"); return; }
      if (!qa.pickD || !qa.pickN) { m.say("請先選方向和距離。", "bad"); return; }
      qa.n++; qa.done = true;
      var right = qa.pickD === qa.d && qa.pickN === qa.dist;
      if (right) qa.ok++;
      m.say((right ? "答對了！" : "不對，正確答案是：") + (right ? "" : DIR[qa.d][2] + "方 " + qa.dist + " 格。") + (qa.n >= 5 ? " 全部完成，得分 " + qa.ok + " / 5。" : ""), right ? "ok" : "bad");
      ok.textContent = qa.n >= 5 ? "再玩一次" : "下一題";
    });
    area.append(qText, h("div", { class: "row" }, "方向：", dirs), h("div", { class: "row" }, "距離：", nums), h("div", { class: "row" }, ok));
    newQ(); show(); refresh(); m.say("請作答。", "info");
  }

  var tb = tabs(["捉老鼠", "方向問答"], function (i) { mode = i; (i === 0 ? chaseUI : quizUI)(); });
  root.append(tb.el, h("div", { class: "row c" }, cv.c), m.el, area);
  window.addEventListener("keydown", function (e) {
    if (mode !== 0) return;
    var d = { ArrowUp: "N", ArrowDown: "S", ArrowLeft: "W", ArrowRight: "E" }[e.key];
    if (d) go(d, 1);
  });
  tb.sel(0);
});

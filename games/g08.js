// 08 井字遊戲：訓練運算能力、智力及一般常識
NMNS.register(8, function (root) {
  var KNOW = [
    ["一年有幾個月？", "12", ["10", "12", "13"]], ["地球上最大的海洋是？", "太平洋", ["大西洋", "太平洋", "印度洋"]],
    ["水在幾度（攝氏）結冰？", "0", ["0", "10", "100"]], ["台灣最高的山是？", "玉山", ["阿里山", "玉山", "雪山"]],
    ["三角形三個內角的和是幾度？", "180", ["90", "180", "360"]], ["1 公尺等於幾公分？", "100", ["10", "100", "1000"]],
    ["彩虹通常分成幾種顏色？", "7", ["5", "7", "9"]], ["太陽系有幾顆行星？", "8", ["7", "8", "9"]],
    ["蝴蝶屬於哪一類動物？", "昆蟲", ["魚類", "昆蟲", "鳥類"]], ["植物行光合作用會吸收哪種氣體？", "二氧化碳", ["氧氣", "二氧化碳", "氮氣"]]
  ];
  var board, over, busy, m = msgBar(), qBox = h("div"), useQ = h("input", { type: "checkbox", checked: "checked", id: "useq" });
  var level = h("select", {}, h("option", { value: "hard" }, "困難（電腦不會輸）"), h("option", { value: "easy" }, "簡單（電腦會失誤）"));
  var grid = h("div", { class: "cellgrid", style: "grid-template-columns:repeat(3,84px);justify-content:center;gap:6px" });
  var LINES = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]];

  function winner(b) { for (var i = 0; i < 8; i++) { var l = LINES[i]; if (b[l[0]] && b[l[0]] === b[l[1]] && b[l[1]] === b[l[2]]) return b[l[0]]; } return b.every(Boolean) ? "T" : null; }
  function minimax(b, turn) {
    var w = winner(b); if (w) return w === "O" ? 1 : w === "X" ? -1 : 0;
    var best = turn === "O" ? -2 : 2;
    for (var i = 0; i < 9; i++) if (!b[i]) {
      b[i] = turn; var s = minimax(b, turn === "O" ? "X" : "O"); b[i] = null;
      if (turn === "O" ? s > best : s < best) best = s;
    }
    return best;
  }
  function aiMove() {
    var empty = [], i;
    for (i = 0; i < 9; i++) if (!board[i]) empty.push(i);
    if (!empty.length) return;
    var mv;
    if (level.value === "easy" && Math.random() < 0.5) mv = pick(empty);
    else {
      var best = -2, cand = [];
      empty.forEach(function (c) { board[c] = "O"; var s = minimax(board, "X"); board[c] = null; if (s > best) { best = s; cand = [c]; } else if (s === best) cand.push(c); });
      mv = pick(cand);
    }
    board[mv] = "O";
  }
  function render() {
    grid.innerHTML = "";
    for (var i = 0; i < 9; i++) (function (i) {
      grid.append(h("button", { class: "cell", type: "button", style: "font-size:2.2rem;min-height:84px;font-weight:700;color:" + (board[i] === "X" ? "#1d4e89" : "#c2410c"), onclick: function () { clickCell(i); } }, board[i] || ""));
    })(i);
  }
  function check() {
    var w = winner(board);
    if (!w) return false;
    over = true; render();
    m.say(w === "X" ? "你贏了！恭喜！" : w === "O" ? "電腦贏了，再接再厲。" : "平手！", w === "X" ? "ok" : w === "O" ? "bad" : "info"); return true;
  }
  function question() {
    if (Math.random() < 0.6) {
      var q = arith(1), opts = [q.a, q.a + 1 + rnd(3), q.a - 1 - rnd(3)].filter(function (v, i, a) { return a.indexOf(v) === i && v >= 0; });
      while (opts.length < 3) opts.push(q.a + 5 + rnd(9));
      return { t: q.q + " = ?", ans: String(q.a), opts: shuffle(opts.map(String)) };
    }
    var k = pick(KNOW); return { t: k[0], ans: k[1], opts: shuffle(k[2]) };
  }
  function place(i) {
    board[i] = "X"; qBox.innerHTML = ""; busy = false;
    if (!check()) { aiMove(); render(); if (!check()) m.say("輪到你了。", "info"); } else render();
  }
  function clickCell(i) {
    if (over || busy || board[i]) return;
    if (!useQ.checked) { place(i); return; }
    busy = true; var q = question();
    qBox.innerHTML = "";
    qBox.append(h("p", { class: "big" }, "答對才能下子：" + q.t), choices(q.opts, function (k, box) {
      var ok = q.opts[k] === q.ans;
      if (ok) { m.say("答對了！", "ok"); place(i); }
      else { qBox.innerHTML = ""; busy = false; board[i] = null; m.say("答錯了（答案：" + q.ans + "），這回合被跳過，換電腦下。", "bad"); aiMove(); render(); check(); }
    }));
  }
  function reset() { board = Array(9).fill(null); over = false; busy = false; qBox.innerHTML = ""; render(); m.say("你是 X，先下。點空格下子。", "info"); }
  level.addEventListener("change", reset);
  root.append(h("div", { class: "row" }, h("label", {}, useQ, " 答題才能下子（運算＋常識）"), level, btn("新的一局", reset, "alt")), m.el, grid, qBox);
  reset();
});

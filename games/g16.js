// 16 轟炸機：包圍戰術、轟炸敵人潛艇、直角座標
NMNS.register(16, function (root) {
  var N = 10, sub, shots, left, hits, over, m = msgBar(), grid = h("div", { class: "cellgrid", style: "grid-template-columns:28px repeat(10,minmax(0,40px));justify-content:center;gap:3px" });
  var state = {};
  function newGame() {
    var horiz = Math.random() < 0.5, r = rnd(horiz ? N : N - 3), c = rnd(horiz ? N - 3 : N);
    sub = []; for (var i = 0; i < 4; i++) sub.push(horiz ? [c + i, r] : [c, r + i]);
    state = {}; left = 20; hits = 0; over = false; render();
    m.say("敵人的潛艇（長 4 格，橫放或直放）藏在 10×10 海域。你有 20 枚炸彈。點格子投彈。", "info");
  }
  function isSub(x, y) { return sub.some(function (s) { return s[0] === x && s[1] === y; }); }
  function near(x, y) { return sub.some(function (s) { return Math.abs(s[0] - x) <= 1 && Math.abs(s[1] - y) <= 1; }); }
  function label(x, y) { return "ABCDEFGHIJ"[x] + (y + 1); }
  function render() {
    grid.innerHTML = ""; grid.append(h("div"));
    for (var x = 0; x < N; x++) grid.append(h("div", { class: "mono", style: "text-align:center" }, "ABCDEFGHIJ"[x]));
    for (var y = 0; y < N; y++) {
      grid.append(h("div", { class: "mono", style: "display:flex;align-items:center;justify-content:center" }, y + 1));
      for (var x2 = 0; x2 < N; x2++) (function (x, y) {
        var s = state[x + "," + y], bg = s === "hit" ? "#e53e3e" : s === "near" ? "#f6e05e" : s === "miss" ? "#bee3f8" : "#e6f0fa", txt = s === "hit" ? "💥" : s === "near" ? "≈" : s === "miss" ? "·" : "";
        if (over && !s && isSub(x, y)) { bg = "#fca5a5"; txt = "▬"; }
        grid.append(h("button", { class: "cell", type: "button", "aria-label": label(x, y), style: "min-height:38px;background:" + bg + ";color:#222", onclick: function () { bomb(x, y); } }, txt));
      })(x2, y);
    }
  }
  function bomb(x, y) {
    if (over || state[x + "," + y]) return; left--;
    var msg;
    if (isSub(x, y)) { state[x + "," + y] = "hit"; hits++; msg = label(x, y) + "：命中！"; }
    else if (near(x, y)) { state[x + "," + y] = "near"; msg = label(x, y) + "：鄰近！潛艇就在隔壁一格內。"; }
    else { state[x + "," + y] = "miss"; msg = label(x, y) + "：落空。"; }
    var kind = state[x + "," + y] === "hit" ? "ok" : "info";
    if (hits === 4) { over = true; m.say("擊沉敵艦！共投 " + (20 - left) + " 枚炸彈。", "ok"); }
    else if (left <= 0) { over = true; m.say("炸彈用完了，潛艇逃走了（紅色是它的位置）。", "bad"); }
    else m.say(msg + "　剩 " + left + " 枚。命中 " + hits + "/4。", kind);
    render();
  }
  root.append(m.el, grid, h("div", { class: "row c" }, btn("新的海域", newGame, "alt")),
    h("p", { class: "link" }, "直角座標：用「欄字母＋列數字」（如 C5）定位。包圍戰術：看到「鄰近」就在四周逐格搜索，命中後沿著直線找出整艘潛艇。"));
  newGame();
});

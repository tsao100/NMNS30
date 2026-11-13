// 04 漢諾爾塔：圓盤搬移，說明遞迴關係
NMNS.register(4, function (root) {
  var W = 600, H = 260, cv = makeCanvas(W, H), g = cv.g, m = msgBar();
  var n = 3, pegs, moves, sel = -1, token = 0, busy = false;
  var nSel = h("select");
  for (var i = 3; i <= 7; i++) nSel.append(h("option", { value: i }, i + " 個圓盤"));
  var info = h("div", { class: "row" });
  var X = [100, 300, 500];
  var colors = ["#e76f51", "#f4a261", "#e9c46a", "#2a9d8f", "#4a8fe7", "#7b6cf6", "#c05299"];

  function reset() {
    token++; busy = false; n = +nSel.value; pegs = [[], [], []];
    for (var i = n; i >= 1; i--) pegs[0].push(i);
    moves = 0; sel = -1; draw(); upd();
    m.say("點一根柱子選取最上面的圓盤，再點目標柱子放下。大盤不能壓在小盤上。", "info");
  }
  function upd(extra) {
    info.textContent = "步數：" + moves + "　最少需要 2^" + n + " − 1 = " + (Math.pow(2, n) - 1) + " 步" + (extra || "");
  }
  function draw() {
    g.clearRect(0, 0, W, H); g.fillStyle = "#fff"; g.fillRect(0, 0, W, H);
    g.fillStyle = "#8d6e63"; g.fillRect(20, H - 24, W - 40, 10);
    for (var p = 0; p < 3; p++) {
      g.fillStyle = sel === p ? "#d4a017" : "#8d6e63";
      g.fillRect(X[p] - 4, 30, 8, H - 54);
      g.fillStyle = "#555"; g.font = "14px sans-serif"; g.textAlign = "center"; g.fillText("ABC"[p], X[p], H - 4);
      pegs[p].forEach(function (d, i) {
        var w = 28 + d * 22, y = H - 24 - (i + 1) * 22;
        g.fillStyle = colors[d - 1]; g.fillRect(X[p] - w / 2, y, w, 20);
        g.strokeStyle = "#333"; g.strokeRect(X[p] - w / 2, y, w, 20);
        g.fillStyle = "#fff"; g.fillText(d, X[p], y + 15);
      });
    }
  }
  function move(a, b) {
    var d = pegs[a].pop(); pegs[b].push(d); moves++; draw();
  }
  function click(p) {
    if (busy) return;
    if (sel < 0) { if (!pegs[p].length) { m.say("這根柱子是空的。", "bad"); return; } sel = p; draw(); return; }
    if (sel === p) { sel = -1; draw(); return; }
    var top = pegs[sel][pegs[sel].length - 1], dst = pegs[p][pegs[p].length - 1];
    if (dst && dst < top) { m.say("不行：大盤不能放在小盤上面。", "bad"); sel = -1; draw(); return; }
    move(sel, p); sel = -1; draw(); upd();
    if (pegs[2].length === n) {
      var best = Math.pow(2, n) - 1;
      m.say(moves === best ? "完美！用了最少步數 " + best + " 步。" : "完成！用了 " + moves + " 步（最少是 " + best + " 步）。", "ok");
    }
  }
  cv.c.addEventListener("click", function (e) {
    var p = canvasPos(cv.c, e).x; click(p < 200 ? 0 : p < 400 ? 1 : 2);
  });
  // 遞迴示範：hanoi(k, from, to, via) 先把 k−1 個搬到輔助柱，再搬最大盤，再把 k−1 個搬回來
  async function demo() {
    reset(); busy = true; var my = token;
    var list = [];
    (function hanoi(k, a, b, c, depth) {
      if (k === 0) return;
      hanoi(k - 1, a, c, b, depth + 1);
      list.push([a, b, k, depth]);
      hanoi(k - 1, c, b, a, depth + 1);
    })(n, 0, 2, 1, 1);
    for (var i = 0; i < list.length; i++) {
      if (my !== token) return;
      var s = list[i];
      move(s[0], s[1]); upd();
      m.say("遞迴：搬第 " + s[2] + " 號圓盤（" + "ABC"[s[0]] + "→" + "ABC"[s[1]] + "），遞迴層數 " + s[3] + "。", "info");
      await sleep(Math.max(120, 900 / n));
    }
    if (my === token) { busy = false; m.say("示範完成！搬 " + n + " 個盤需要 " + moves + " 步 = 2^" + n + " − 1。T(n) = 2·T(n−1) + 1。", "ok"); }
  }
  nSel.addEventListener("change", reset);
  root.append(h("div", { class: "row" }, nSel, btn("重新排列", reset, "alt"), btn("遞迴自動示範", demo)), info, m.el, cv.c,
    h("p", { class: "link" }, "遞迴想法：要搬 n 個盤，先把上面 n−1 個搬到輔助柱，再搬最大盤，最後把 n−1 個搬回來。"));
  reset();
});

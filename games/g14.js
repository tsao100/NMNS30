// 14 智慧盤：奇排列與偶排列的性質
NMNS.register(14, function (root) {
  captureArrows();
  var m = msgBar(), area = h("div"), cur = null, handoff = null;

  function inversions(a) { var c = 0; for (var i = 0; i < 16; i++) for (var j = i + 1; j < 16; j++) if (a[i] && a[j] && a[i] > a[j]) c++; return c; }
  function solvable(a) { var r = Math.floor(a.indexOf(0) / 4); return (inversions(a) + (3 - r)) % 2 === 0; }
  function solved() { var a = []; for (var i = 1; i < 16; i++) a.push(i); a.push(0); return a; }
  function scramble() {
    var a = solved(), z = 15, last = -1;
    for (var k = 0; k < 120; k++) {
      var nb = []; [[1, 0], [-1, 0], [0, 1], [0, -1]].forEach(function (d) { var x = z % 4 + d[0], y = Math.floor(z / 4) + d[1]; if (x >= 0 && x < 4 && y >= 0 && y < 4 && y * 4 + x !== last) nb.push(y * 4 + x); });
      var t = pick(nb); a[z] = a[t]; a[t] = 0; last = z; z = t;
    }
    return a;
  }
  function board(a, onClick, sel) {
    var gr = h("div", { class: "cellgrid", style: "grid-template-columns:repeat(4,64px);justify-content:center;gap:4px" });
    a.forEach(function (v, i) {
      gr.append(h("button", { class: "cell", type: "button", style: "min-height:64px;font-size:1.4rem;font-weight:700;border-radius:8px;" + (v ? "background:#fde68a;color:#1f2933;" : "background:transparent;border-style:dashed;") + (sel === i ? "outline:3px solid #d64545;" : ""), "aria-label": v ? "第 " + v + " 片" : "空格", onclick: function () { onClick(i); } }, v || ""));
    });
    return gr;
  }

  function play(start) {
    area.innerHTML = ""; var a = start ? start.slice() : scramble(), moves = 0, bw = h("div"), info = h("div", { class: "row" });
    function upd() {
      var inv = inversions(a); info.textContent = "步數 " + moves + "　逆序數 " + inv + "（" + (inv % 2 ? "奇" : "偶") + "排列）";
      bw.innerHTML = ""; bw.append(board(a, tap));
      if (a.every(function (v, i) { return v === (i === 15 ? 0 : i + 1); })) m.say("完成！用了 " + moves + " 步。", "ok");
    }
    function tap(i) {
      var z = a.indexOf(0), dx = Math.abs(i % 4 - z % 4), dy = Math.abs(Math.floor(i / 4) - Math.floor(z / 4));
      if (dx + dy === 1) { a[z] = a[i]; a[i] = 0; moves++; upd(); }
    }
    window.onkeydown = function (e) {
      var z = a.indexOf(0), t = { ArrowUp: z + 4, ArrowDown: z - 4, ArrowLeft: z + 1, ArrowRight: z - 1 }[e.key];
      if (t == null || t < 0 || t > 15) return; if ((e.key === "ArrowLeft" && z % 4 === 3) || (e.key === "ArrowRight" && z % 4 === 0)) return; tap(t);
    };
    area.append(h("div", { class: "row" }, btn("重新洗牌", function () { play(); }, "alt")), info, bw, h("p", { class: "link" }, "點旁邊的拼圖或用方向鍵（方向鍵＝拼圖移動的方向）。目標：1～15 依序排好，空格在右下角。"));
    upd(); m.say("把數字排回 1、2、3…15。這個盤面一定有解。", "info");
  }

  function lab() {
    area.innerHTML = ""; var a = handoff ? handoff.slice() : solved(), first = -1, bw = h("div"), info = h("div", { class: "msg info" });
    function upd() {
      var inv = inversions(a), ok = solvable(a), z = a.indexOf(0), r = 4 - Math.floor(z / 4);
      info.innerHTML = "逆序數（排在後面卻比較小的配對數）= <b>" + inv + "</b>，是 <b>" + (inv % 2 ? "奇" : "偶") + "排列</b>；空格在由下往上第 " + r + " 列。<br>判斷：" +
        "逆序數 + 空格由下數的列數（從 0 算）= " + (inv + r - 1) + " → " + ((inv + r - 1) % 2 === 0 ? "偶數，<b style='color:var(--ok)'>有解</b>" : "奇數，<b style='color:var(--bad)'>無解</b>");
      bw.innerHTML = ""; bw.append(board(a, function (i) {
        if (first < 0) { first = i; upd(); return; } var t = a[first]; a[first] = a[i]; a[i] = t; first = -1; upd();
      }, first));
      play2.disabled = !ok;
    }
    var play2 = btn("玩這個排列", function () { play(a); });
    area.append(h("p", {}, "排列實驗室：點兩格就能交換位置（空格也可以）。交換兩片會把奇排列變偶排列、偶變奇，所以一次交換就可能讓盤面從有解變無解！"),
      h("div", { class: "row" }, btn("還原", function () { handoff = null; first = -1; a = solved(); upd(); }, "alt"), btn("隨機排列", function () { a = shuffle(a); first = -1; upd(); }, "alt"), play2), info, bw);
    upd(); m.say("試試只交換 14 和 15：逆序數變成奇數，無解！", "info");
  }
  var tb = tabs(["玩智慧盤", "排列實驗室"], function (i) { window.onkeydown = null; if (i === 0) play(); else lab(); });
  root.append(tb.el, m.el, area); tb.sel(0);
});

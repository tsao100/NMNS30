// 10 抽大頭（阿彌陀籤）：走線條遊戲，介紹數學函數觀念及應用
NMNS.register(10, function (root) {
  var N = 6, L = 9, W = 640, Hh = 400, cv = makeCanvas(W, Hh), g = cv.g, m = msgBar();
  var COL = ["#e63946", "#f4a261", "#2a9d8f", "#457b9d", "#8338ec", "#6d6875"];
  var A, B, two = false, anim = 0, shown = {}, back = false;
  var tbl = h("div"), chk = h("input", { type: "checkbox", id: "two" });

  function makeLadder() {
    var r = [];
    for (var l = 0; l < L; l++) {
      r.push(Array(N - 1).fill(false));
      for (var c = 0; c < N - 1; c++) if (Math.random() < 0.45 && !(c > 0 && r[l][c - 1])) r[l][c] = true;
    }
    return r;
  }
  function trace(r, s, rev) { // 回傳經過的格點 [[col, level]...] 與終點
    var c = s, pts = [[c, 0]], ls = rev ? Array.from({ length: L }, function (_, i) { return L - 1 - i; }) : Array.from({ length: L }, function (_, i) { return i; });
    ls.forEach(function (l) {
      pts.push([c, l + 1]); var d = 0;
      if (c < N - 1 && r[l][c]) d = 1; else if (c > 0 && r[l][c - 1]) d = -1;
      if (d) { c += d; pts.push([c, l + 1]); }
    });
    pts.push([c, L + 1]); return { pts: pts, end: c };
  }
  function f(r, x) { return trace(r, x, false).end; }
  function finv(r, y) { for (var x = 0; x < N; x++) if (f(r, x) === y) return x; return -1; }
  function geom(off) { return { x0: off + 30, dx: (two ? 130 : 110), y0: 50, dy: 28 }; }
  function draw(partial) {
    g.fillStyle = "#fff"; g.fillRect(0, 0, W, Hh);
    drawOne(A, two ? 10 : 140, "A"); if (two) drawOne(B, 340, "B");
    g.lineWidth = 4;
    Object.keys(shown).forEach(function (k) {
      var s = shown[k], gm = s.which === "A" ? (two ? 10 : 140) : 340, G = geom(gm), upto = partial && partial.key === k ? partial.n : s.pts.length;
      g.strokeStyle = COL[s.color]; g.beginPath();
      for (var i = 0; i < upto; i++) { var p = s.pts[i], X = G.x0 + p[0] * (two ? 40 : 66) - (two ? 0 : 20), Y = G.y0 + p[1] * G.dy - (p[1] === 0 ? 0 : 0); i ? g.lineTo(X, Y) : g.moveTo(X, Y); }
      g.stroke();
    });
  }
  function colX(which, c) { var off = which === "A" ? (two ? 10 : 140) : 340; return off + 30 + c * (two ? 40 : 66) - (two ? 0 : 20); }
  function drawOne(r, off, name) {
    var G = geom(off), sp = two ? 40 : 66;
    g.strokeStyle = "#555"; g.lineWidth = 2; g.font = "bold 14px sans-serif"; g.textAlign = "center"; g.fillStyle = "#222";
    var ox = off + 30 - (two ? 0 : 20);
    for (var c = 0; c < N; c++) {
      g.beginPath(); g.moveTo(ox + c * sp, G.y0); g.lineTo(ox + c * sp, G.y0 + (L + 1) * G.dy); g.stroke();
      g.fillText(c + 1, ox + c * sp, G.y0 - 10); g.fillText(c + 1, ox + c * sp, G.y0 + (L + 1) * G.dy + 20);
    }
    for (var l = 0; l < L; l++) for (var c2 = 0; c2 < N - 1; c2++) if (r[l][c2]) { g.beginPath(); g.moveTo(ox + c2 * sp, G.y0 + (l + 1) * G.dy); g.lineTo(ox + (c2 + 1) * sp, G.y0 + (l + 1) * G.dy); g.stroke(); }
    g.fillStyle = "#666"; g.font = "13px sans-serif"; g.fillText("籤 " + name + "：輸入 x → 輸出 f(x)", ox + sp * 2.5, 20);
  }
  function table() {
    var rows = [], x;
    for (x = 0; x < N; x++) rows.push(h("tr", {}, h("td", {}, x + 1), h("td", {}, f(A, x) + 1), two ? h("td", {}, f(B, f(A, x)) + 1) : null));
    tbl.innerHTML = "";
    tbl.append(h("table", { class: "t" }, h("tr", {}, h("th", {}, "x"), h("th", {}, "f(x)"), two ? h("th", {}, "g(f(x))") : null), rows));
  }
  function run(x, which) { // 動畫走一條
    var r = which === "A" ? A : B, color = x, key = which + x, tr = trace(r, x, false), id = ++anim;
    shown[key] = { pts: tr.pts, color: color, which: which };
    var n = 1;
    (function step() { if (id !== anim && !shown[key]) return; draw({ key: key, n: n }); if (n < tr.pts.length) { n++; setTimeout(step, 40); } })();
    return tr.end;
  }
  function clearPaths() { shown = {}; draw(); }
  function reset() { A = makeLadder(); B = makeLadder(); two = chk.checked; clearPaths(); table(); m.say("點上方數字，看這條路徑最後走到哪裡；每個起點對應唯一終點，就是「函數」。", "info"); }
  cv.c.addEventListener("click", function (e) {
    var p = canvasPos(cv.c, e);
    ["A", "B"].forEach(function (w) {
      if (w === "B" && !two) return;
      for (var c = 0; c < N; c++) {
        if (Math.abs(p.x - colX(w, c)) < 18 && p.y < 50) { var end = run(c, w); m.say("籤 " + w + "：f(" + (c + 1) + ") = " + (end + 1), "ok"); }
        if (Math.abs(p.x - colX(w, c)) < 18 && p.y > 50 + (L + 1) * 28 - 5) {
          var r = w === "A" ? A : B, x = finv(r, c); shown = {}; var tr = trace(r, x, false);
          shown[w + x] = { pts: tr.pts, color: x, which: w }; draw();
          m.say("反函數：終點 " + (c + 1) + " 是從起點 " + (x + 1) + " 走來的，即 f⁻¹(" + (c + 1) + ") = " + (x + 1), "ok");
        }
      }
    });
  });
  root.append(h("div", { class: "row" }, btn("換一張新籤", reset), btn("全部走一遍", function () { for (var x = 0; x < N; x++) run(x, "A"); m.say("6 條路徑終點都不同：這是一對一的函數，所以可以找反函數。", "info"); }, "alt"), btn("清除路徑", clearPaths, "alt"),
    h("label", {}, chk, " 串接第二張籤（函數合成）")), m.el, cv.c, tbl,
    h("p", { class: "link" }, "點上方數字＝走一條路徑（求 f(x)）；點下方數字＝反查是從哪個起點來的（反函數）；串接兩張籤得到合成函數 g(f(x))。"));
  chk.addEventListener("change", reset);
  reset();
});

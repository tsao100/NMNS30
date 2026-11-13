// 18 楊輝三角形（巴斯卡三角形）：結構及應用
NMNS.register(18, function (root) {
  var ROWS = 14, tri = [], m = msgBar(), area = h("div"), hl = {}, mode = 0;
  for (var r = 0; r < ROWS; r++) { tri.push([]); for (var c = 0; c <= r; c++) tri[r].push(c === 0 || c === r ? 1 : tri[r - 1][c - 1] + tri[r - 1][c]); }
  function fib(n) { var a = 1, b = 1; for (var i = 1; i < n; i++) { var t = a + b; a = b; b = t; } return a; }
  var view = h("div", { style: "overflow-x:auto;padding:6px 0" });

  function render(colorFn, onClick) {
    view.innerHTML = "";
    var box = h("div", { style: "display:inline-block;min-width:100%;text-align:center" });
    tri.forEach(function (row, r) {
      var line = h("div", { style: "white-space:nowrap;line-height:2" });
      row.forEach(function (v, c) {
        var st = colorFn ? colorFn(r, c, v) : "";
        line.append(h("span", { class: "mono", style: "display:inline-block;min-width:3.4em;border-radius:6px;margin:0 1px;cursor:pointer;" + st, onclick: function () { onClick && onClick(r, c, v); } }, v));
      });
      box.append(line);
    });
    view.append(box);
  }
  function structure() {
    hl = {}; area.innerHTML = "";
    function draw(sel) {
      render(function (r, c) { var k = r + "," + c; return hl[k] === 2 ? "background:#fbbf24;font-weight:700;" : hl[k] === 1 ? "background:#bfdbfe;" : ""; }, function (r, c, v) {
        hl = {}; hl[r + "," + c] = 2;
        if (r > 0) { if (c > 0) hl[(r - 1) + "," + (c - 1)] = 1; if (c < r) hl[(r - 1) + "," + c] = 1; }
        draw();
        m.say(r === 0 || c === 0 || c === r ? v + "：每一列的兩端都是 1。" : v + " = " + tri[r - 1][c - 1] + " + " + tri[r - 1][c] + "（正上方兩個數相加）。", "info");
      });
    }
    draw(); m.say("點任何一個數，看它是由上面哪兩個數相加而來。", "info");
  }
  function odd() {
    area.innerHTML = ""; render(function (r, c, v) { return v % 2 ? "background:#f59e0b;color:#111;" : "color:#9ca3af;"; });
    m.say("把奇數塗色，會出現一層層的小三角形（謝爾賓斯基三角形）。再多排幾列就是碎形圖案。", "info");
  }
  function sums() {
    area.innerHTML = ""; render(null);
    var tb = h("table", { class: "t" }, h("tr", {}, h("th", {}, "第 n 列"), h("th", {}, "數字總和"), h("th", {}, "2ⁿ")));
    tri.forEach(function (row, r) { tb.append(h("tr", {}, h("td", {}, r), h("td", {}, row.join(" + ") + " = " + row.reduce(function (a, b) { return a + b; }, 0)), h("td", {}, Math.pow(2, r)))); });
    area.append(h("div", { style: "overflow-x:auto" }, tb)); m.say("每一列的總和都是 2 的 n 次方（n 從 0 開始算）。", "info");
  }
  function fibs() {
    var d = 1, sel = h("input", { type: "range", min: 1, max: 12, value: 5 }), out = h("div", { class: "msg info" });
    function upd() {
      d = +sel.value; var cells = {}, terms = [];
      for (var j = 0; j <= d; j++) { var r = d - j; if (r >= 0 && j <= r) { cells[r + "," + j] = 1; terms.push(tri[r][j]); } }
      render(function (r, c) { return cells[r + "," + c] ? "background:#6ee7b7;font-weight:700;" : ""; });
      out.textContent = "斜線 " + d + "：" + terms.join(" + ") + " = " + terms.reduce(function (a, b) { return a + b; }, 0) + "，剛好是費氏數列的第 " + (d + 1) + " 項 " + fib(d + 1);
    }
    area.innerHTML = ""; area.append(h("div", { class: "row" }, "選擇斜線：", sel), out); sel.addEventListener("input", upd); upd();
    m.say("沿著淺斜線（往右上方走）把數字加起來，會得到 1, 1, 2, 3, 5, 8…費氏數列。", "info");
  }
  function expand() {
    area.innerHTML = ""; var sel = h("input", { type: "range", min: 0, max: 10, value: 4 }), out = h("div", { class: "msg info big mono", style: "overflow-x:auto" });
    function upd() {
      var n = +sel.value, parts = [];
      for (var k = 0; k <= n; k++) { var co = tri[n][k]; parts.push((co === 1 ? "" : co) + (n - k ? "a" + (n - k > 1 ? "^" + (n - k) : "") : "") + (k ? "b" + (k > 1 ? "^" + k : "") : "")); }
      out.textContent = "(a+b)^" + n + " = " + (parts.join(" + ") || "1");
      render(function (r) { return r === n ? "background:#c4b5fd;font-weight:700;" : ""; });
    }
    area.append(h("div", { class: "row" }, "n =", sel), out); sel.addEventListener("input", upd); upd();
    m.say("(a+b)ⁿ 展開後各項的係數，就是三角形第 n 列。", "info");
  }
  function comb() {
    area.innerHTML = ""; var ni = h("input", { type: "number", min: 0, max: ROWS - 1, value: 6 }), ki = h("input", { type: "number", min: 0, max: ROWS - 1, value: 2 }), out = h("div", { class: "msg info big" });
    function upd() {
      var n = clamp(Math.round(+ni.value) || 0, 0, ROWS - 1), k = clamp(Math.round(+ki.value) || 0, 0, n);
      out.textContent = "C(" + n + ", " + k + ") = " + tri[n][k] + "　（從 " + n + " 個東西挑出 " + k + " 個的方法數）";
      render(function (r, c) { return r === n && c === k ? "background:#fb7185;color:#fff;font-weight:700;" : ""; });
    }
    area.append(h("div", { class: "row" }, "n =", ni, "k =", ki), out); [ni, ki].forEach(function (e) { e.addEventListener("input", upd); }); upd();
    m.say("三角形第 n 列（從 0 算）的第 k 個數（從 0 算）就是 C(n, k)。", "info");
  }
  var fn = [structure, odd, sums, fibs, expand, comb];
  var tb = tabs(["結構", "奇偶圖案", "列的總和", "費氏數列", "二項式展開", "組合數"], function (i) { mode = i; fn[i](); });
  root.append(tb.el, m.el, area, view);
  tb.sel(0);
});

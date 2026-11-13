// 11 排方塊：質數、合成數觀念及辨別方式
NMNS.register(11, function (root) {
  var m = msgBar(), area = h("div");
  function isPrime(n) { if (n < 2) return false; for (var i = 2; i * i <= n; i++) if (n % i === 0) return false; return true; }
  function kind(n) { return n === 1 ? "既不是質數也不是合成數" : isPrime(n) ? "質數" : "合成數"; }

  function blocks() {
    area.innerHTML = "";
    var inp = h("input", { type: "number", min: 1, max: 100, value: 12 }), out = h("div");
    function show() {
      var n = clamp(Math.round(+inp.value) || 1, 1, 100); out.innerHTML = "";
      var f = []; for (var a = 1; a <= n; a++) if (n % a === 0) f.push(a);
      out.append(h("p", { class: "big" }, n + " 是" + kind(n) + "（因數有 " + f.length + " 個：" + f.join("、") + "）"));
      var wrap = h("div", { class: "row" });
      f.forEach(function (a) {
        var b = n / a; if (a > b) return;
        var sz = n > 60 ? 8 : n > 30 ? 11 : 14;
        var gr = h("div", { style: "display:grid;gap:2px;grid-template-columns:repeat(" + b + "," + sz + "px)" });
        for (var i = 0; i < n; i++) gr.append(h("span", { style: "width:" + sz + "px;height:" + sz + "px;background:#2b6cb0;border-radius:2px" }));
        wrap.append(h("div", { class: "card", style: "align-items:center" }, h("span", { class: "ed" }, a + " × " + b), gr));
      });
      out.append(wrap, h("p", { class: "link" }, "能排成的長方形種類：" + wrap.children.length + " 種。" + (isPrime(n) ? "質數只能排成 1 × " + n + " 一種。" : n === 1 ? "" : "合成數可以排成不只一種長方形。")));
    }
    inp.addEventListener("input", show);
    area.append(h("div", { class: "row" }, "方塊數量 n =", inp, btn("隨機", function () { inp.value = 2 + rnd(60); show(); }, "alt")), out); show();
    m.say("輸入方塊數量，看看能排成哪些「長方形」。", "info");
  }

  function sieve() {
    area.innerHTML = "";
    var state = Array(101).fill(0), p = 1, cells = [], grid = h("div", { class: "cellgrid", style: "grid-template-columns:repeat(10,minmax(0,38px));justify-content:center" });
    for (var i = 1; i <= 100; i++) { var c = h("div", { class: "cell", style: "min-height:34px;cursor:default" }, i); cells[i] = c; grid.append(c); }
    function paint() {
      for (var i = 1; i <= 100; i++) {
        var s = state[i], st = cells[i].style;
        st.background = i === 1 ? "#d1d5db" : s === 2 ? "#fbbf24" : s === 1 ? "#e5e7eb" : "var(--bg)";
        st.color = s === 1 ? "#9ca3af" : "var(--ink)"; st.fontWeight = s === 2 ? "700" : "400";
      }
    }
    var next = btn("下一步", function () {
      do { p++; } while (p <= 10 && state[p] === 1);
      if (p > 10) {
        for (var i = 2; i <= 100; i++) if (state[i] === 0) state[i] = 2;
        paint(); m.say("完成！亮黃色的 25 個數是 100 以內的質數。", "ok"); next.disabled = true; return;
      }
      state[p] = 2; for (var k = p * p; k <= 100; k += p) if (state[k] !== 2) state[k] = 1;
      paint(); m.say("留下 " + p + "（質數），劃掉它的倍數。", "info");
    });
    area.append(h("p", {}, "埃拉托斯特尼篩法：從 2 開始，留下質數，劃掉它所有的倍數。"), next, grid); paint();
    m.say("按「下一步」，一步一步找出 100 以內的質數。", "info");
  }

  function quiz() {
    area.innerHTML = ""; var n = 0, ok = 0, box = h("div");
    function q() {
      box.innerHTML = "";
      if (n >= 8) { m.say("測驗完成：" + ok + " / 8。", ok >= 7 ? "ok" : "info"); box.append(btn("再測一次", quiz)); return; }
      var v = Math.random() < 0.12 ? 1 : 2 + rnd(98), ans = kind(v).slice(0, 2);
      box.append(h("p", { class: "big" }, "第 " + (n + 1) + " / 8 題：" + v + " 是什麼？"), choices(["質數", "合成數", "都不是"], function (i) {
        var right = ["質數", "合成數", "都不是"][i].slice(0, 2) === ans.slice(0, 2) || (v === 1 && i === 2);
        if (right) ok++; n++;
        var f = []; for (var a = 1; a <= v; a++) if (v % a === 0) f.push(a);
        m.say((right ? "答對！" : "答錯。") + v + " 的因數：" + f.join("、") + "（" + kind(v) + "）", right ? "ok" : "bad"); setTimeout(q, 1200);
      }));
    }
    area.append(box); q();
  }
  var tb = tabs(["排方塊", "質數篩", "辨別測驗"], function (i) { [blocks, sieve, quiz][i](); });
  root.append(tb.el, m.el, area);
  tb.sel(0);
});

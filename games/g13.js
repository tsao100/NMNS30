// 13 找找看：數目猜測、排序及電腦搜尋基本功能
NMNS.register(13, function (root) {
  var m = msgBar(), area = h("div");

  function guess() {
    area.innerHTML = "";
    var secret = 1 + rnd(1000), lo = 1, hi = 1000, tries = 0, over = false;
    var inp = h("input", { type: "number", min: 1, max: 1000, value: 500 }), rng = h("div", { class: "big" });
    function upd() { rng.textContent = "範圍：" + lo + " ～ " + hi + "　已猜 " + tries + " 次"; }
    var go = btn("猜！", function () {
      if (over) return; var v = Math.round(+inp.value);
      if (!(v >= 1 && v <= 1000)) { m.say("請輸入 1～1000。", "bad"); return; }
      tries++;
      if (v === secret) { over = true; m.say("猜中了！答案是 " + secret + "，共 " + tries + " 次。（二分法最多只要 10 次）", "ok"); }
      else if (v < secret) { lo = Math.max(lo, v + 1); m.say(v + " 太小了，比它大。", "info"); }
      else { hi = Math.min(hi, v - 1); m.say(v + " 太大了，比它小。", "info"); }
      upd();
    });
    area.append(h("p", {}, "我在 1～1000 之間想了一個數，你來猜。每次猜完我會告訴你太大或太小。"), rng, h("div", { class: "row" }, inp, go, btn("換一個數", guess, "alt"))); upd();
    m.say("提示：每次猜範圍的正中間，最多 10 次就能猜中！", "info");
  }

  function compGuess() {
    area.innerHTML = ""; var lo = 1, hi = 100, tries = 0, cur = 50, over = false, box = h("div");
    var txt = h("p", { class: "big" });
    function show() { txt.textContent = over ? "" : "我猜是 " + cur + "（可能範圍 " + lo + "～" + hi + "）"; }
    function ans(r) {
      if (over) return; tries++;
      if (r === 0) { over = true; m.say("我用了 " + tries + " 次猜中 " + cur + "！二分搜尋每次都砍掉一半的可能。", "ok"); show(); return; }
      if (r < 0) hi = cur - 1; else lo = cur + 1;
      if (lo > hi) { over = true; m.say("咦，你的回答互相矛盾，沒有數字符合囉。", "bad"); show(); return; }
      cur = Math.floor((lo + hi) / 2); show(); m.say("第 " + (tries + 1) + " 次猜測。", "info");
    }
    area.append(h("p", {}, "請在心裡想一個 1～100 的數（先不要說）。我會用「二分法」來猜。"), txt,
      h("div", { class: "row" }, btn("太大了", function () { ans(-1); }), btn("太小了", function () { ans(1); }), btn("答對了", function () { ans(0); }), btn("重來", compGuess, "alt")), box);
    show(); m.say("你的回答是「我的數字比它大／小」。", "info");
  }

  function compare() {
    area.innerHTML = "";
    var arr = []; for (var i = 0; i < 40; i++) arr.push(3 * i + 2 + rnd(2));
    var cells = [], grid = h("div", { class: "cellgrid", style: "grid-template-columns:repeat(10,minmax(0,52px));justify-content:center" });
    arr.forEach(function (v, i) { var c = h("div", { class: "cell", style: "min-height:32px;cursor:default;font-size:.85rem" }, v); cells.push(c); grid.append(c); });
    var res = h("div"), token = 0;
    async function run() {
      var my = ++token, t = arr[rnd(40)]; if (Math.random() < 0.15) t += 1000;
      cells.forEach(function (c) { c.style.background = "var(--bg)"; });
      res.textContent = "目標：" + t + (t > 500 ? "（其實根本不存在）" : "") + "　先用「循序搜尋」從頭一個一個找…";
      var lin = 0, found = -1;
      for (var i = 0; i < 40; i++) { if (my !== token) return; lin++; cells[i].style.background = "#fde68a"; await sleep(30); if (arr[i] === t) { found = i; break; } }
      if (found >= 0) cells[found].style.background = "#34d399";
      await sleep(400); cells.forEach(function (c) { c.style.background = "var(--bg)"; });
      var l = 0, r = 39, bin = 0; found = -1;
      while (l <= r) {
        if (my !== token) return; var mid = (l + r) >> 1; bin++; cells[mid].style.background = "#93c5fd"; await sleep(500);
        if (arr[mid] === t) { found = mid; break; } if (arr[mid] < t) l = mid + 1; else r = mid - 1;
      }
      if (found >= 0) cells[found].style.background = "#34d399";
      res.innerHTML = "目標 " + t + "：循序搜尋比較了 <b>" + lin + "</b> 次；二分搜尋只比較 <b>" + bin + "</b> 次。資料要先「排序」才能用二分搜尋。";
      m.say("資料量越大，兩種方法差越多。", "ok");
    }
    area.append(h("p", {}, "下面是已排序的 40 個數。比較兩種搜尋方法要看幾個數才能找到目標。"), grid, h("div", { class: "row" }, btn("開始比較（新目標）", run)), res);
    m.say("按「開始比較」。黃色是循序搜尋看過的，藍色是二分搜尋看過的。", "info");
  }
  var tb = tabs(["我猜你的數", "你猜我的數", "搜尋大比拼"], function (i) { [guess, compGuess, compare][i](); });
  root.append(tb.el, m.el, area);
  tb.sel(0);
});

// 12 排排看：氣泡、插入、交換、合併排序法
NMNS.register(12, function (root) {
  var W = 640, Hh = 260, cv = makeCanvas(W, Hh), g = cv.g, m = msgBar();
  var ALG = { bubble: "氣泡排序", insertion: "插入排序", selection: "交換（選擇）排序", merge: "合併排序" };
  var algS = h("select"), nS = h("select"), initS = h("select"), spd = h("input", { type: "range", min: 1, max: 100, value: 60 });
  Object.keys(ALG).forEach(function (k) { algS.append(h("option", { value: k }, ALG[k])); });
  [10, 20, 30].forEach(function (v) { nS.append(h("option", { value: v }, v + " 個")); });
  [["rand", "隨機"], ["rev", "完全反序"], ["near", "幾乎已排好"]].forEach(function (o) { initS.append(h("option", { value: o[0] }, o[1])); });
  var stat = h("div", { class: "row" }), token = 0, data = [];
  var raceBox = h("div");

  function makeData() {
    var n = +nS.value, a = []; for (var i = 1; i <= n; i++) a.push(i);
    if (initS.value === "rand") a = shuffle(a);
    else if (initS.value === "rev") a.reverse();
    else { for (var k = 0; k < 3; k++) { var x = rnd(n - 1), t = a[x]; a[x] = a[x + 1]; a[x + 1] = t; } }
    return a;
  }
  // 產生每一步畫面：{a, hi:[...], cmp, mov}
  function frames(alg, src) {
    var a = src.slice(), f = [], cmp = 0, mov = 0;
    function push(hi) { f.push({ a: a.slice(), hi: hi || [], cmp: cmp, mov: mov }); }
    push();
    if (alg === "bubble") {
      for (var i = a.length - 1; i > 0; i--) for (var j = 0; j < i; j++) {
        cmp++; push([j, j + 1]);
        if (a[j] > a[j + 1]) { var t = a[j]; a[j] = a[j + 1]; a[j + 1] = t; mov++; push([j, j + 1]); }
      }
    } else if (alg === "insertion") {
      for (var i2 = 1; i2 < a.length; i2++) {
        var key = a[i2], j2 = i2 - 1;
        while (j2 >= 0) { cmp++; push([j2, i2]); if (a[j2] > key) { a[j2 + 1] = a[j2]; mov++; j2--; push([j2 + 1]); } else break; }
        a[j2 + 1] = key; mov++; push([j2 + 1]);
      }
    } else if (alg === "selection") {
      for (var i3 = 0; i3 < a.length - 1; i3++) {
        var mi = i3;
        for (var j3 = i3 + 1; j3 < a.length; j3++) { cmp++; push([mi, j3]); if (a[j3] < a[mi]) mi = j3; }
        if (mi !== i3) { var t2 = a[i3]; a[i3] = a[mi]; a[mi] = t2; mov++; push([i3, mi]); }
      }
    } else {
      (function ms(l, r) {
        if (r - l < 1) return;
        var mid = (l + r) >> 1; ms(l, mid); ms(mid + 1, r);
        var tmp = [], i = l, j = mid + 1;
        while (i <= mid && j <= r) { cmp++; push([i, j]); tmp.push(a[i] <= a[j] ? a[i++] : a[j++]); }
        while (i <= mid) tmp.push(a[i++]); while (j <= r) tmp.push(a[j++]);
        for (var k = 0; k < tmp.length; k++) { a[l + k] = tmp[k]; mov++; push([l + k]); }
      })(0, a.length - 1);
    }
    push(); return f;
  }
  function draw(fr, final) {
    g.fillStyle = "#fff"; g.fillRect(0, 0, W, Hh);
    var n = fr.a.length, bw = (W - 20) / n;
    fr.a.forEach(function (v, i) {
      g.fillStyle = final ? "#2f855a" : fr.hi.indexOf(i) >= 0 ? "#e53e3e" : "#4a8fe7";
      var bh = v / n * (Hh - 20); g.fillRect(10 + i * bw + 1, Hh - 5 - bh, bw - 2, bh);
    });
    stat.textContent = "比較 " + fr.cmp + " 次　搬動／交換 " + fr.mov + " 次";
  }
  async function play(alg) {
    var my = ++token, fs = frames(alg, data);
    m.say(ALG[alg] + " 執行中…（紅色是正在比較／移動的長條）", "info");
    for (var i = 0; i < fs.length; i++) {
      if (my !== token) return; draw(fs[i], false);
      await sleep(Math.max(2, 400 / (1 + +spd.value * 0.6)));
    }
    draw(fs[fs.length - 1], true);
    m.say(ALG[alg] + " 完成：比較 " + fs[fs.length - 1].cmp + " 次、搬動 " + fs[fs.length - 1].mov + " 次。", "ok");
  }
  function reset() { token++; data = makeData(); draw({ a: data, hi: [], cmp: 0, mov: 0 }, false); m.say("選演算法按「開始排序」，或試試下面的「猜一猜」。", "info"); raceBox.innerHTML = ""; }
  function race() {
    var ks = shuffle(Object.keys(ALG)).slice(0, 2); token++; data = makeData(); draw({ a: data, hi: [], cmp: 0, mov: 0 }, false);
    var fa = frames(ks[0], data), fb = frames(ks[1], data), ca = fa[fa.length - 1], cb = fb[fb.length - 1];
    var ta = ca.cmp + ca.mov, tb = cb.cmp + cb.mov;
    raceBox.innerHTML = "";
    raceBox.append(h("p", { class: "big" }, "猜一猜：同一組資料，哪個方法的（比較＋搬動）總次數比較少？"),
      choices([ALG[ks[0]], ALG[ks[1]], "一樣多"], function (i) {
        var right = (i === 0 && ta < tb) || (i === 1 && tb < ta) || (i === 2 && ta === tb);
        m.say((right ? "猜對了！" : "猜錯了。") + ALG[ks[0]] + "：" + ta + " 次；" + ALG[ks[1]] + "：" + tb + " 次。", right ? "ok" : "bad");
      }));
  }
  [algS, nS, initS].forEach(function (e) { e.addEventListener("change", reset); });
  root.append(h("div", { class: "row" }, algS, nS, initS), h("div", { class: "row" }, btn("開始排序", function () { play(algS.value); }), btn("新資料", reset, "alt"), btn("猜一猜", race, "alt"), "速度", spd),
    stat, m.el, cv.c, raceBox,
    h("p", { class: "link" }, "氣泡：相鄰兩個比大小、換位。插入：把新牌插到前面已排好的位置。交換（選擇）：每次找最小的換到前面。合併：分成兩半各自排好再合併，資料多時最快。"));
  reset();
});

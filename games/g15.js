// 15 二進位制：由猜數遊戲說明二進位數字原理
NMNS.register(15, function (root) {
  var m = msgBar(), area = h("div");
  var W = [1, 2, 4, 8, 16, 32];

  function mind() {
    area.innerHTML = ""; var k = 0, total = 0, box = h("div");
    function card() {
      box.innerHTML = "";
      if (k >= 6) {
        box.append(h("p", { class: "big" }, "你想的數字是 " + total + "！"),
          h("p", {}, "把「有」的卡片最上面的數加起來：" + (total ? W.filter(function (w) { return total & w; }).join(" + ") + " = " + total : "全部都沒有 = 0（你想的是 1～63，請重來）")),
          btn("再玩一次", mind));
        m.say("魔術的秘密：每張卡片的第一個數是 1、2、4、8、16、32，也就是二進位每一位的值。", "ok"); return;
      }
      var nums = []; for (var n = 1; n <= 63; n++) if (n & W[k]) nums.push(n);
      var gr = h("div", { class: "cellgrid", style: "grid-template-columns:repeat(8,minmax(0,40px));justify-content:center" });
      nums.forEach(function (n) { gr.append(h("div", { class: "cell", style: "cursor:default;min-height:30px;font-size:.9rem" + (n === W[k] ? ";background:#fde68a;font-weight:700" : "") }, n)); });
      box.append(h("p", { class: "big" }, "第 " + (k + 1) + " 張卡片：你想的數字在這張卡片上嗎？"), gr,
        h("div", { class: "row c" }, btn("有", function () { total += W[k]; k++; card(); }), btn("沒有", function () { k++; card(); })));
    }
    area.append(box); card(); m.say("請在心裡想一個 1～63 的數字，回答 6 張卡片，我就能猜出來。", "info");
  }

  function bulbs() {
    area.innerHTML = ""; var bits = [0, 0, 0, 0, 0, 0], target = 1 + rnd(63), row = h("div", { class: "row c" }), val = h("div", { class: "big", style: "text-align:center" });
    function show() {
      row.innerHTML = "";
      for (var i = 5; i >= 0; i--) (function (i) {
        row.append(h("div", { style: "text-align:center" }, h("div", { class: "mono" }, W[i]),
          h("button", { class: "btn", type: "button", style: "width:54px;height:54px;border-radius:50%;font-size:1.4rem;" + (bits[i] ? "background:#f59e0b;border-color:#f59e0b;color:#111" : "background:#374151;border-color:#374151;color:#9ca3af"), "aria-label": "位值 " + W[i], onclick: function () { bits[i] ^= 1; show(); } }, bits[i])));
      })(i);
      var v = bits.reduce(function (s, b, i) { return s + b * W[i]; }, 0);
      val.textContent = "二進位 " + bits.slice().reverse().join("") + " = 十進位 " + v;
      if (v === target) m.say("對了！" + target + " 的二進位就是 " + bits.slice().reverse().join("") + "。", "ok");
    }
    area.append(h("p", { class: "big" }, "挑戰：用燈泡（1＝亮，0＝暗）組出十進位數字 " + target), row, val,
      h("div", { class: "row c" }, btn("換一題", bulbs, "alt"), btn("全部熄滅", function () { bits = [0, 0, 0, 0, 0, 0]; show(); }, "alt"))); show();
    m.say("每個燈泡代表 1、2、4、8、16、32；亮的燈加起來就是十進位。", "info");
  }
  var tb = tabs(["心電感應猜數", "燈泡轉換"], function (i) { [mind, bulbs][i](); });
  root.append(tb.el, m.el, area);
  tb.sel(0);
});

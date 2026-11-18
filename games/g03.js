// 03 雞兔同籠：實例分析及練習四則應用問題
NMNS.register(3, function (root) {
  var probs = [], idx = 0, score = 0, tried = false;
  var m = msgBar(), box = h("div"), pic = h("div", { class: "big", style: "word-break:break-all" });

  function crProblem() {
    var c = 2 + rnd(12), r = 2 + rnd(10);
    return { t: "籠子裡有雞和兔，共有 " + (c + r) + " 個頭、" + (2 * c + 4 * r) + " 隻腳。雞和兔各有幾隻？", f: ["雞", "兔"], a: [c, r],
      hint: ["假設全部都是雞：腳有 " + 2 * (c + r) + " 隻。", "實際多出 " + (2 * c + 4 * r - 2 * (c + r)) + " 隻腳，每隻兔比雞多 2 隻腳。", "兔 = " + (2 * c + 4 * r - 2 * (c + r)) + " ÷ 2 = " + r + "，雞 = " + (c + r) + " − " + r + " = " + c + "。"], pic: "🐔".repeat(c) + "🐇".repeat(r) };
  }
  function coinProblem() {
    var a = 2 + rnd(8), b = 2 + rnd(8);
    return { t: "撲滿裡有 10 元和 5 元的硬幣，共 " + (a + b) + " 枚，合計 " + (10 * a + 5 * b) + " 元。10 元和 5 元各有幾枚？", f: ["10 元", "5 元"], a: [a, b],
      hint: ["假設全都是 5 元：共 " + 5 * (a + b) + " 元。", "多出 " + (10 * a + 5 * b - 5 * (a + b)) + " 元，每換一枚 10 元多 5 元。", "10 元 = " + (10 * a + 5 * b - 5 * (a + b)) + " ÷ 5 = " + a + " 枚，5 元 = " + b + " 枚。"] };
  }
  function changeProblem() {
    var p = 5 + rnd(20), n = 2 + rnd(8), pay = Math.ceil((p * n + 1) / 50) * 50;
    return { t: "每個麵包 " + p + " 元，買 " + n + " 個，付 " + pay + " 元，應找回多少元？", f: ["找回"], a: [pay - p * n],
      hint: ["總價 = " + p + " × " + n + " = " + p * n + " 元。", "找回 = " + pay + " − " + p * n + " = " + (pay - p * n) + " 元。"] };
  }
  function shareProblem() {
    var k = 3 + rnd(7), each = 4 + rnd(9), extra = 2 + rnd(8);
    return { t: "有 " + k * each + " 顆糖平均分給 " + k + " 位小朋友，每人再多得 " + extra + " 顆。每人共得幾顆？", f: ["每人"], a: [each + extra],
      hint: ["先平分：" + k * each + " ÷ " + k + " = " + each + " 顆。", "再加 " + extra + " 顆：" + each + " + " + extra + " = " + (each + extra) + " 顆。"] };
  }
  function build() {
    probs = [crProblem(), crProblem(), crProblem(), coinProblem(), coinProblem(), changeProblem(), changeProblem(), shareProblem()];
    idx = 0; score = 0; show();
  }
  function show() {
    box.innerHTML = ""; pic.textContent = ""; tried = false;
    if (idx >= probs.length) { NMNS.finish(3, score); m.say("全部完成！答對 " + score + " / " + probs.length + " 題。按「重新開始」再玩。", "ok"); return; }
    var p = probs[idx], ins = [];
    var form = h("div", { class: "row" });
    p.f.forEach(function (lab) { var i = h("input", { type: "number", "aria-label": lab }); ins.push(i); form.append(lab + "：", i); });
    var hintBox = h("div", { class: "msg info", style: "display:none" });
    var go = btn("送出答案", function () {
      var ok = ins.every(function (i, k) { return Number(i.value) === p.a[k] && i.value !== ""; });
      if (ok) {
        if (!tried) score++;
        m.say("答對了！" + (tried ? "（看過提示，不計分）" : ""), "ok"); if (p.pic) pic.textContent = p.pic;
        go.disabled = true; hintBtn.disabled = true; nextBtn.style.display = "";
      } else { tried = true; m.say("再想想看，也可以按「看解法提示」。", "bad"); }
    });
    var hintBtn = btn("看解法提示", function () { tried = true; hintBox.style.display = ""; hintBox.innerHTML = p.hint.join("<br>"); }, "alt");
    var nextBtn = btn(idx === probs.length - 1 ? "看成績" : "下一題", function () { idx++; show(); }); nextBtn.style.display = "none";
    box.append(h("p", { class: "big" }, "第 " + (idx + 1) + " / " + probs.length + " 題"), h("p", {}, p.t), form, h("div", { class: "row" }, go, hintBtn, nextBtn), hintBox);
    m.say("算出答案後填入。", "info");
  }
  root.append(box, m.el, pic);
  build();
});

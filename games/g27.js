// 27 動物識別：依動物特徵辨識動物
NMNS.register(27, function (root) {
  // 名稱, 腳數, 體表, 生殖, 棲地, 食性, 會飛
  var A = [
    ["狗", 4, "F", "L", "L", "O", 0], ["貓", 4, "F", "L", "L", "C", 0], ["牛", 4, "F", "L", "L", "H", 0], ["豬", 4, "B", "L", "L", "O", 0], ["大象", 4, "B", "L", "L", "H", 0],
    ["雞", 2, "K", "E", "L", "O", 0], ["鴨", 2, "K", "E", "B", "O", 1], ["老鷹", 2, "K", "E", "L", "C", 1], ["麻雀", 2, "K", "E", "L", "O", 1], ["企鵝", 2, "K", "E", "B", "C", 0],
    ["蝙蝠", 2, "F", "L", "L", "C", 1], ["青蛙", 4, "B", "E", "B", "C", 0], ["蛇", 0, "S", "E", "L", "C", 0], ["金魚", 0, "S", "E", "W", "O", 0], ["鱷魚", 4, "S", "E", "B", "C", 0],
    ["烏龜", 4, "H", "E", "B", "O", 0], ["鯨魚", 0, "B", "L", "W", "C", 0], ["蝴蝶", 6, "H", "E", "L", "H", 1], ["螞蟻", 6, "H", "E", "L", "O", 0], ["蜘蛛", 8, "H", "E", "L", "C", 0]
  ];
  var COV = { F: "身上有毛", K: "身上有羽毛", S: "身上有鱗片", H: "有硬殼（硬的外骨骼）", B: "皮膚光滑" };
  var BR = { E: "從蛋孵出來", L: "直接生小寶寶" }, HM = { L: "住在陸地", W: "住在水裡", B: "水陸兩棲" }, DT = { H: "只吃植物", C: "只吃動物", O: "植物動物都吃" };
  var QS = [
    ["有 4 隻腳嗎？", function (a) { return a[1] === 4; }], ["有 2 隻腳嗎？", function (a) { return a[1] === 2; }], ["沒有腳嗎？", function (a) { return a[1] === 0; }], ["有 6 隻以上的腳嗎？", function (a) { return a[1] >= 6; }],
    ["身上有毛嗎？", function (a) { return a[2] === "F"; }], ["身上有羽毛嗎？", function (a) { return a[2] === "K"; }], ["身上有鱗片嗎？", function (a) { return a[2] === "S"; }], ["有硬殼嗎？", function (a) { return a[2] === "H"; }],
    ["是從蛋孵出來的嗎？", function (a) { return a[3] === "E"; }], ["只住在陸地上嗎？", function (a) { return a[4] === "L"; }], ["只住在水裡嗎？", function (a) { return a[4] === "W"; }],
    ["會飛嗎？", function (a) { return a[6] === 1; }], ["只吃植物嗎？", function (a) { return a[5] === "H"; }], ["只吃動物嗎？", function (a) { return a[5] === "C"; }]
  ];
  var m = msgBar(), area = h("div");
  function clues(a, idx) {
    var all = [a[1] ? "有 " + a[1] + " 隻腳" : "沒有腳", COV[a[2]], BR[a[3]], HM[a[4]], DT[a[5]], a[6] ? "會飛" : "不會飛"]; return idx.map(function (i) { return all[i]; });
  }
  function describe(a) { return clues(a, [0, 1, 2, 3, 4, 5]).join("；"); }

  function guessMode() {
    area.innerHTML = ""; var alive = A.map(function (_, i) { return i; }), asked = {}, n = 0, box = h("div"), done = false;
    area.append(h("p", {}, "在心裡想一種動物（不要說），我來猜："), h("p", { class: "pill" }, A.map(function (a) { return a[0]; }).join("、")), box);
    function ask() {
      if (done) return; box.innerHTML = "";
      if (alive.length <= 1) { done = true; return end(); }
      var best = -1, bd = 99;
      QS.forEach(function (q, i) { if (asked[i]) return; var y = alive.filter(function (k) { return q[1](A[k]); }).length; if (y > 0 && y < alive.length && Math.abs(2 * y - alive.length) < bd) { bd = Math.abs(2 * y - alive.length); best = i; } });
      if (best < 0) { done = true; return end(); }
      asked[best] = 1; n++;
      box.append(h("p", { class: "big" }, "問題 " + n + "：" + QS[best][0] + "（還剩 " + alive.length + " 種可能）"),
        h("div", { class: "row" }, btn("是", function () { alive = alive.filter(function (k) { return QS[best][1](A[k]); }); ask(); }), btn("不是", function () { alive = alive.filter(function (k) { return !QS[best][1](A[k]); }); ask(); })));
    }
    function end() {
      box.innerHTML = "";
      if (!alive.length) { m.say("沒有任何動物符合你的回答，可能中間答錯了。", "bad"); box.append(btn("重來", guessMode)); return; }
      var a = A[alive[0]]; box.append(h("p", { class: "big" }, "我猜是：" + a[0] + "！"), h("p", {}, "特徵：" + describe(a)), btn("再玩一次", guessMode));
      m.say("用特徵一步步縮小範圍，就能認出動物。", "ok");
    }
    ask(); m.say("請誠實回答是／不是。", "info");
  }
  function clueMode() {
    area.innerHTML = ""; var r = 0, score = 0, box = h("div");
    function round() {
      box.innerHTML = ""; if (r >= 8) { m.say("動物識別：" + score + " / 8。", score >= 7 ? "ok" : "info"); box.append(btn("再玩一次", clueMode)); return; }
      var ai = rnd(A.length), a = A[ai], idx = shuffle([0, 1, 2, 3, 4, 5]).slice(0, 4), opts = [ai];
      var tries = 0; while (opts.length < 4 && tries++ < 500) { var b = rnd(A.length); if (opts.indexOf(b) >= 0) continue; var bc = clues(A[b], idx).join("|"), ac = clues(a, idx).join("|"); if (bc !== ac) opts.push(b); }
      opts = shuffle(opts);
      box.append(h("p", { class: "big" }, "第 " + (r + 1) + " / 8 題：這是什麼動物？"), h("ul", {}, clues(a, idx).map(function (c) { return h("li", {}, c); })),
        choices(opts.map(function (k) { return A[k][0]; }), function (i) {
          var ok = opts[i] === ai; if (ok) score++; r++; m.say((ok ? "答對了！" : "不對，是" + a[0] + "。") + "特徵：" + describe(a), ok ? "ok" : "bad"); setTimeout(round, 1800);
        }));
    }
    area.append(box); round(); m.say("根據特徵選出動物。", "info");
  }
  var tb = tabs(["我猜你想的動物", "看特徵認動物"], function (i) { [guessMode, clueMode][i](); });
  root.append(tb.el, m.el, area, h("p", { class: "link" }, "分類特徵：腳數、體表、生殖方式、棲地、食性、會不會飛。蝙蝠有毛、生小寶寶，是哺乳類；鯨魚住水裡但用肺呼吸，也是哺乳類。"));
  tb.sel(0);
});

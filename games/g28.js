// 28 大門牙：牙齒構造、種類、功能及正確保養
NMNS.register(28, function (root) {
  var m = msgBar(), area = h("div"), timer = 0;
  // 每排 16 顆（中間是門牙）：臼齒3 前臼齒2 犬齒1 門齒2 | 門齒2 犬齒1 前臼齒2 臼齒3
  var TYPES = ["臼齒", "臼齒", "臼齒", "前臼齒", "前臼齒", "犬齒", "門齒", "門齒", "門齒", "門齒", "犬齒", "前臼齒", "前臼齒", "臼齒", "臼齒", "臼齒"];
  var INFO = {
    門齒: ["共 8 顆（上下各 4）。扁平像鑿子，負責咬斷食物，例如咬蘋果。也幫助說話發音。", "#fef3c7"],
    犬齒: ["共 4 顆（上下各 2）。尖尖的，負責撕裂食物，牙根最長。", "#fde68a"],
    前臼齒: ["共 8 顆（上下各 4）。有兩個小尖，負責壓碎、磨碎食物。", "#d9f99d"],
    臼齒: ["共 12 顆（上下各 6），含 4 顆智齒。表面寬大，負責磨碎食物。", "#bbf7d0"]
  };
  function stop() { clearInterval(timer); }
  function toothShape(g, x, y, w, hgt, type, up, col, plaque) {
    g.fillStyle = col; g.strokeStyle = "#a8a29e"; g.lineWidth = 1.5; g.beginPath();
    var dir = up ? 1 : -1;
    if (type === "門齒") { g.rect(x - w / 2, y, w, hgt * dir); }
    else if (type === "犬齒") { g.moveTo(x - w / 2, y); g.lineTo(x + w / 2, y); g.lineTo(x, y + hgt * dir * 1.15); g.closePath(); }
    else { g.rect(x - w / 2, y, w, hgt * dir * .8); }
    g.fill(); g.stroke();
    if (plaque) { g.fillStyle = "rgba(120,80,20,.8)"; g.beginPath(); g.arc(x, y + dir * hgt * .45, w * .28, 0, 7); g.fill(); }
  }
  function drawChart(g, W, Hh, sel, plaq) {
    g.fillStyle = "#fff"; g.fillRect(0, 0, W, Hh); g.fillStyle = "#fecdd3"; g.fillRect(0, 100, W, 36); g.fillRect(0, 164, W, 36);
    var sp = (W - 40) / 16, rects = [];
    for (var j = 0; j < 2; j++) for (var i = 0; i < 16; i++) {
      var type = TYPES[i], x = 20 + sp * (i + .5), up = j === 0, y = up ? 100 : 200, hgt = type === "門齒" ? 56 : 48, w = (type === "門齒" ? 0.82 : type === "犬齒" ? 0.75 : 0.9) * sp;
      toothShape(g, x, y, w, hgt, type, !up, sel && sel.type === type ? INFO[type][1] : "#fff", plaq && plaq[j + "," + i]);
      if (sel && sel.type === type) { g.strokeStyle = "#ea580c"; g.lineWidth = 2.5; g.strokeRect(x - w / 2 - 1, up ? 42 : 200, w + 2, 58); }
      rects.push({ x: x, j: j, i: i, w: w, type: type });
    }
    g.fillStyle = "#555"; g.font = "13px sans-serif"; g.textAlign = "center"; g.fillText("上排牙齒", W / 2, 22); g.fillText("下排牙齒", W / 2, Hh - 6);
    return rects;
  }
  function learn() {
    stop(); area.innerHTML = ""; var cv = makeCanvas(640, 260), sel = null, info = h("div", { class: "msg info" }, "點任何一顆牙齒，看它的名稱和功能。");
    function paint() { drawChart(cv.g, 640, 260, sel, null); } paint();
    cv.c.addEventListener("click", function (e) {
      var p = canvasPos(cv.c, e), sp = (640 - 40) / 16, i = Math.floor((p.x - 20) / sp); if (i < 0 || i > 15) return;
      sel = { type: TYPES[i] }; paint(); info.innerHTML = "<b>" + sel.type + "</b>：" + INFO[sel.type][0];
    });
    area.append(cv.c, info, h("p", { class: "link" }, "成人共 32 顆牙：門齒 8、犬齒 4、前臼齒 8、臼齒 12（含智齒）。小朋友的乳牙有 20 顆，沒有前臼齒。"));
    m.say("認識牙齒的種類與功能。", "info");
  }
  function anatomy() {
    stop(); area.innerHTML = ""; var cv = makeCanvas(420, 340), g = cv.g, info = h("div", { class: "msg info" }, "點牙齒的各個部位。");
    var parts = [
      ["琺瑯質", "牙齒最外層，是人體最硬的部分，保護牙齒；受損後不會再生，要避免酸和糖的侵蝕。", [210, 50]],
      ["象牙質", "在琺瑯質裡面，比較軟，含有細小管道會傳遞冷熱痠痛。", [165, 120]],
      ["牙髓", "牙齒中心，有神經與血管，提供養分，蛀牙蛀到這裡會很痛。", [210, 190]],
      ["牙齦（牙肉）", "包住牙根的粉紅色軟組織，要溫柔刷，不要刷傷。", [330, 190]],
      ["牙根", "埋在牙齦和齒槽骨裡，把牙齒固定住。", [210, 285]],
      ["牙菌斑", "附在牙面的細菌薄膜，吃了糖會產酸，造成蛀牙；要靠刷牙清除。", [300, 80]]
    ];
    g.fillStyle = "#fff"; g.fillRect(0, 0, 420, 340); g.fillStyle = "#fb7185"; g.fillRect(70, 150, 280, 120);
    g.fillStyle = "#fde68a"; g.beginPath(); g.moveTo(150, 150); g.quadraticCurveTo(140, 20, 210, 20); g.quadraticCurveTo(280, 20, 270, 150); g.lineTo(255, 320); g.lineTo(225, 320); g.lineTo(210, 220); g.lineTo(195, 320); g.lineTo(165, 320); g.closePath(); g.fill();
    g.fillStyle = "#fff"; g.beginPath(); g.moveTo(150, 150); g.quadraticCurveTo(138, 18, 210, 14); g.quadraticCurveTo(282, 18, 270, 150); g.lineTo(262, 150); g.quadraticCurveTo(268, 36, 210, 32); g.quadraticCurveTo(152, 36, 158, 150); g.fill();
    g.strokeStyle = "#a8a29e"; g.stroke();
    g.fillStyle = "#f87171"; g.fillRect(200, 130, 20, 120); g.fillStyle = "#c2410c"; g.beginPath(); g.arc(300, 85, 9, 0, 7); g.fill();
    g.fillStyle = "#111"; g.font = "13px sans-serif"; g.textAlign = "center";
    parts.forEach(function (p) { g.fillStyle = "#111"; g.beginPath(); g.arc(p[2][0], p[2][1], 5, 0, 7); g.fill(); g.fillText(p[0], p[2][0], p[2][1] - 9); });
    cv.c.addEventListener("click", function (e) {
      var pt = canvasPos(cv.c, e), best = null, bd = 60; parts.forEach(function (p) { var d = Math.hypot(pt.x - p[2][0], pt.y - p[2][1]); if (d < bd) { bd = d; best = p; } });
      if (best) info.innerHTML = "<b>" + best[0] + "</b>：" + best[1];
    });
    area.append(cv.c, info); m.say("牙齒的構造（剖面圖）。", "info");
  }
  function quiz() {
    stop(); area.innerHTML = ""; var q = 0, ok = 0, box = h("div"), cv = makeCanvas(640, 260);
    var FACTS = [["門齒的功能是？", ["咬斷食物", "磨碎食物", "撕裂食物"], 0], ["尖尖的、負責撕裂食物的是？", ["門齒", "犬齒", "臼齒"], 1], ["成人共有幾顆牙齒（含智齒）？", ["20", "28", "32"], 2], ["人體最硬的部分是？", ["骨頭", "琺瑯質", "指甲"], 1], ["小朋友的乳牙共有幾顆？", ["20", "24", "32"], 0], ["下列哪一個比較容易讓牙齒蛀掉？", ["常吃甜食又不刷牙", "吃青菜", "喝白開水"], 0], ["一天至少要刷牙幾次？", ["1 次", "2 次（早晚）", "不一定要刷"], 1], ["牙醫建議多久換一次牙刷？", ["一年", "三個月左右", "壞掉才換"], 1]];
    function next() {
      box.innerHTML = ""; if (q >= FACTS.length + 4) { m.say("測驗完成：" + ok + " / " + (FACTS.length + 4) + "。", ok >= 10 ? "ok" : "info"); box.append(btn("再測一次", quiz)); return; }
      if (q < 4) {
        var ti = rnd(16), type = TYPES[ti], sel = { type: "none" }, plq = {}; var rects = drawChart(cv.g, 640, 260, null, null);
        var g = cv.g, sp = (640 - 40) / 16, x = 20 + sp * (ti + .5), j = rnd(2); g.fillStyle = "rgba(234,88,12,.5)"; g.fillRect(x - sp / 2, j ? 200 : 42, sp, 58);
        box.append(cv.c, h("p", { class: "big" }, "第 " + (q + 1) + " 題：橘色框住的是哪一種牙齒？"), choices(["門齒", "犬齒", "前臼齒", "臼齒"], function (i) {
          var right = ["門齒", "犬齒", "前臼齒", "臼齒"][i] === type; if (right) ok++; q++; m.say((right ? "答對！" : "答錯，是" + type + "。") + INFO[type][0], right ? "ok" : "bad"); setTimeout(next, 1700);
        }));
      } else {
        var f = FACTS[q - 4]; box.append(h("p", { class: "big" }, "第 " + (q + 1) + " 題：" + f[0]), choices(f[1], function (i) {
          var right = i === f[2]; if (right) ok++; q++; m.say(right ? "答對了！" : "答錯，正確答案：" + f[1][f[2]], right ? "ok" : "bad"); setTimeout(next, 1200);
        }));
      }
    }
    area.append(box); next(); m.say("牙齒知識測驗。", "info");
  }
  function brush() {
    stop(); area.innerHTML = ""; var cv = makeCanvas(640, 260), g = cv.g, plq = {}, left = 60, score = 0, hurts = 0, over = false, started = false, rects;
    var order = h("div", { class: "msg info" }, "正確刷牙：牙刷與牙齒成 45 度，一次刷 2～3 顆，輕輕畫小圓；外面、內面、咬合面都要刷，最後別忘了舌頭。（點黃褐色的牙菌斑把它刷掉！點到牙齦會刷傷喔！）");
    function spawn() { var k = rnd(2) + "," + rnd(16); plq[k] = 1; }
    function paint() { rects = drawChart(g, 640, 260, null, plq); }
    function end() { over = true; stop(); m.say("時間到！刷掉 " + score + " 塊牙菌斑，刷傷牙齦 " + hurts + " 次。" + (hurts === 0 ? "很溫柔！" : "刷牙要輕一點。"), score >= 15 ? "ok" : "info"); }
    var info = h("div", { class: "row" });
    cv.c.addEventListener("click", function (e) {
      if (over) return; if (!started) { started = true; timer = setInterval(function () { left--; if (Object.keys(plq).length < 14 && Math.random() < .8) spawn(); if (left <= 0) end(); info.textContent = "剩 " + left + " 秒　已清除 " + score + "　刷傷牙齦 " + hurts; paint(); }, 1000); }
      var p = canvasPos(cv.c, e), sp = (640 - 40) / 16;
      if ((p.y > 100 && p.y < 136) || (p.y > 164 && p.y < 200)) { hurts++; m.say("刷到牙齦了！要輕輕刷。", "bad"); }
      else { var i = Math.floor((p.x - 20) / sp), j = p.y < 150 ? 0 : 1; if (plq[j + "," + i]) { delete plq[j + "," + i]; score++; m.say("清掉一塊牙菌斑！", "ok"); } }
      info.textContent = "剩 " + left + " 秒　已清除 " + score + "　刷傷牙齦 " + hurts; paint();
    });
    for (var i = 0; i < 6; i++) spawn(); paint(); info.textContent = "剩 60 秒（點第一下開始計時）";
    area.append(info, cv.c, order); m.say("在 60 秒內清掉牙菌斑。", "info");
  }
  var fn = [learn, anatomy, quiz, brush];
  var tb = tabs(["認識牙齒", "牙齒構造", "知識測驗", "刷牙遊戲"], function (i) { fn[i](); });
  root.append(tb.el, m.el, area);
  tb.sel(0);
});

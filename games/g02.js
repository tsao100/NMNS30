// 02 偵探與怪盜：角色扮演，訓練思考、推理及判斷力
NMNS.register(2, function (root) {
  var ATTR = {
    hat: { name: "帽子", vals: { 1: "戴帽子", 0: "沒戴帽子" } },
    glass: { name: "眼鏡", vals: { 1: "戴眼鏡", 0: "沒戴眼鏡" } },
    scarf: { name: "圍巾", vals: { 紅: "紅色圍巾", 藍: "藍色圍巾", 綠: "綠色圍巾" } },
    tall: { name: "身高", vals: { 1: "個子高", 0: "個子矮" } }
  };
  var SC = { 紅: "#d64545", 藍: "#3b6fd4", 綠: "#2f9e5b" };
  var sus, thief, asked, crossed, over, m = msgBar();
  var board = h("div", { class: "grid", style: "grid-template-columns:repeat(auto-fill,minmax(130px,1fr))" });
  var attrSel = h("select"), valSel = h("select"), log = h("ul");

  function key(s) { return [s.hat, s.glass, s.scarf, s.tall].join("|"); }
  function newGame() {
    var seen = {}; sus = [];
    while (sus.length < 8) {
      var s = { hat: rnd(2), glass: rnd(2), scarf: pick(["紅", "藍", "綠"]), tall: rnd(2) };
      if (!seen[key(s)]) { seen[key(s)] = 1; sus.push(s); }
    }
    thief = rnd(8); asked = 0; crossed = {}; over = false; log.innerHTML = "";
    m.say("我是偵探。怪盜就在這 8 位嫌犯之中！問的問題越少，分數越高。", "info");
    render();
  }
  function render() {
    board.innerHTML = "";
    sus.forEach(function (s, i) {
      var face = (s.hat ? "🎩" : "　") + "🙂" + (s.glass ? "👓" : "");
      var card = h("div", { class: "card", style: "align-items:center;text-align:center;" + (crossed[i] ? "opacity:.35;" : "") },
        h("span", { class: "no" }, "嫌犯 " + (i + 1)),
        h("span", { style: "font-size:1.8rem" }, face),
        h("span", { style: "width:100%;height:10px;border-radius:5px;background:" + SC[s.scarf] }),
        h("span", { class: "ed" }, "圍巾" + s.scarf + "・" + (s.tall ? "高" : "矮")),
        h("div", { class: "acts" },
          btn(crossed[i] ? "取消排除" : "排除", function () { if (!over) { crossed[i] = !crossed[i]; render(); } }, "alt sm"),
          btn("指認", function () { accuse(i); }, "sm")));
      board.append(card);
    });
  }
  function accuse(i) {
    if (over) return;
    over = true;
    var score = Math.max(0, 100 - asked * 10 - (i === thief ? 0 : 60));
    NMNS.finish(2, score);
    if (i === thief) m.say("抓到怪盜了！你問了 " + asked + " 個問題，得分 " + score + "。", "ok");
    else m.say("抓錯人了！真正的怪盜是嫌犯 " + (thief + 1) + "。得分 " + score + "。按「重新開始」再玩。", "bad");
  }
  function fillVals() {
    valSel.innerHTML = "";
    var a = ATTR[attrSel.value];
    Object.keys(a.vals).forEach(function (v) { valSel.append(h("option", { value: v }, a.vals[v])); });
  }
  Object.keys(ATTR).forEach(function (k) { attrSel.append(h("option", { value: k }, ATTR[k].name)); });
  attrSel.addEventListener("change", fillVals); fillVals();

  var ask = btn("問偵探助手", function () {
    if (over) return;
    var a = attrSel.value, v = valSel.value, yes = String(sus[thief][a]) === v;
    asked++;
    log.append(h("li", {}, "怪盜" + ATTR[a].vals[v] + "嗎？ → " + (yes ? "是" : "不是")));
    m.say("已問 " + asked + " 題。用答案把嫌犯排除，最後按「指認」。", "info");
  });
  root.append(
    h("p", {}, "怪盜有 4 個特徵：帽子、眼鏡、圍巾顏色、身高。選一個問題問助手（只回答是／不是），推理後指認。"),
    h("div", { class: "row" }, "怪盜", attrSel, valSel, "？", ask),
    m.el, board, h("p", { class: "link" }, "問答紀錄："), log);
  newGame();
});

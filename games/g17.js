// 17 強棒出擊：四位數字排列組合，訓練解題能力
NMNS.register(17, function (root) {
  var m = msgBar(), secret, hist, cand, over, MAX = 10;
  var inp = h("input", { type: "text", inputmode: "numeric", maxlength: 4, placeholder: "例：0123", style: "width:7em;font-size:1.2rem", "aria-label": "四位數字" });
  var hl = h("table", { class: "t" }), cnt = h("div", { class: "pill" }), show = h("input", { type: "checkbox", id: "sc", checked: "checked" });
  var all = [];
  for (var i = 0; i < 10000; i++) { var s = String(i).padStart(4, "0"); if (new Set(s).size === 4) all.push(s); }

  function score(sec, g) { var st = 0, b = 0; for (var i = 0; i < 4; i++) { if (g[i] === sec[i]) st++; else if (sec.indexOf(g[i]) >= 0) b++; } return [st, b]; }
  function newGame() {
    secret = pick(all); hist = []; cand = all.slice(); over = false; inp.value = ""; render();
    m.say("電腦想了 4 個「不重複」的數字（可以 0 開頭）。猜猜看，10 次機會！", "info");
  }
  function render() {
    hl.innerHTML = "";
    hl.append(h("tr", {}, h("th", {}, "次"), h("th", {}, "你猜的"), h("th", {}, "好球（位置數字都對）"), h("th", {}, "壞球（數字對位置錯）")));
    hist.forEach(function (r, i) { hl.append(h("tr", {}, h("td", {}, i + 1), h("td", { class: "mono big" }, r.g), h("td", {}, "⚾".repeat(r.s) || "—"), h("td", {}, "●".repeat(r.b) || "—"))); });
    cnt.textContent = show.checked ? "還有 " + cand.length + " 種可能（一開始有 5040 種）" : "";
  }
  function guess() {
    if (over) return; var g = inp.value.trim();
    if (!/^\d{4}$/.test(g) || new Set(g).size !== 4) { m.say("請輸入 4 個不重複的數字。", "bad"); return; }
    if (hist.some(function (r) { return r.g === g; })) { m.say("這個猜過了。", "bad"); return; }
    var sc = score(secret, g); hist.push({ g: g, s: sc[0], b: sc[1] });
    cand = cand.filter(function (c) { var t = score(c, g); return t[0] === sc[0] && t[1] === sc[1]; });
    inp.value = ""; render();
    if (sc[0] === 4) { over = true; m.say("全壘打！你用 " + hist.length + " 次猜中 " + secret + "！", "ok"); }
    else if (hist.length >= MAX) { over = true; m.say("10 次用完了。答案是 " + secret + "。", "bad"); }
    else m.say(sc[0] + " 好球、" + sc[1] + " 壞球。還有 " + (MAX - hist.length) + " 次機會。", "info");
  }
  inp.addEventListener("keydown", function (e) { if (e.key === "Enter") guess(); });
  show.addEventListener("change", render);
  root.append(h("div", { class: "row" }, inp, btn("擊球", guess), btn("新的一局", newGame, "alt"), h("label", {}, show, " 顯示剩餘可能數")), cnt, m.el, hl,
    h("p", { class: "link" }, "排列：從 10 個數字中取 4 個排隊，共 10×9×8×7 = 5040 種。每次回饋都能淘汰許多可能，推理就是一直縮小範圍。"));
  newGame();
});

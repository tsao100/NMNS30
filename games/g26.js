// 26 螳螂捕蟬：食物鏈、生物食性關係
NMNS.register(26, function (root) {
  captureArrows();
  var m = msgBar(), area = h("div"), chaseKey = null, chaseTimer = 0;
  var CHAINS = [["青草", "蚱蜢", "青蛙", "蛇"], ["樹葉", "毛毛蟲", "小鳥", "老鷹"], ["藻類", "水蚤", "小魚", "大魚"], ["玉米", "老鼠", "蛇", "貓頭鷹"], ["植物汁液", "蟬", "螳螂", "黃雀"], ["青草", "兔子", "狐狸", "狼"]];
  var DIET = [["牛", 0], ["獅子", 1], ["豬", 2], ["蟬（吸植物汁液）", 0], ["螳螂（吃昆蟲）", 1], ["黑熊", 2], ["兔子", 0], ["青蛙（吃昆蟲）", 1], ["烏鴉", 2], ["貓熊（主食竹子）", 0]];
  var DN = ["草食動物（吃植物）", "肉食動物（吃動物）", "雜食動物（植物動物都吃）"];
  function stop() { clearInterval(chaseTimer); chaseKey = null; }

  function chainQuiz() {
    stop(); area.innerHTML = ""; var q = 0, ok = 0, order = shuffle([0, 1, 2, 3, 4, 5]).slice(0, 5), box = h("div");
    function next() {
      box.innerHTML = ""; if (q >= 5) { m.say("食物鏈測驗：" + ok + " / 5。", ok >= 4 ? "ok" : "info"); box.append(btn("再玩一次", chainQuiz)); return; }
      var ch = CHAINS[order[q]], mix = shuffle([0, 1, 2, 3]), pickd = [], row = h("div", { class: "row" }), sol = h("div", { class: "big" });
      box.append(h("p", { class: "big" }, "第 " + (q + 1) + " / 5 題：依序點出食物鏈（從最先被吃的開始）"));
      mix.forEach(function (i) {
        var b = btn(ch[i], function () {
          if (b.disabled) return; if (i !== pickd.length) { m.say("順序不對，再想想：箭頭由「被吃的」指向「吃它的」。", "bad"); pickd = []; row.querySelectorAll("button").forEach(function (x) { x.disabled = false; x.classList.remove("good"); }); sol.textContent = ""; return; }
          pickd.push(i); b.disabled = true; b.classList.add("good"); sol.textContent = pickd.map(function (k) { return ch[k]; }).join(" → ");
          if (pickd.length === 4) { ok++; q++; m.say("正確！" + ch.join(" → "), "ok"); setTimeout(next, 1300); }
        }, "choice"); row.append(b);
      }); box.append(row, sol);
    }
    area.append(box); next(); m.say("食物鏈的箭頭指向吃它的動物。", "info");
  }
  function dietQuiz() {
    stop(); area.innerHTML = ""; var q = 0, ok = 0, order = shuffle(DIET.map(function (_, i) { return i; })).slice(0, 8), box = h("div");
    function next() {
      box.innerHTML = ""; if (q >= 8) { m.say("食性測驗：" + ok + " / 8。", ok >= 7 ? "ok" : "info"); box.append(btn("再玩一次", dietQuiz)); return; }
      var d = DIET[order[q]];
      box.append(h("p", { class: "big" }, "第 " + (q + 1) + " / 8 題：" + d[0] + " 屬於？"), choices(DN, function (i) {
        var right = i === d[1]; if (right) ok++; q++; m.say((right ? "答對！" : "答錯，正確是：" + DN[d[1]]), right ? "ok" : "bad"); setTimeout(next, 1000);
      }));
    }
    area.append(box); next(); m.say("看看動物吃什麼，就知道牠的食性。", "info");
  }
  function chase() {
    area.innerHTML = ""; var W = 24, H = 16, S = 24, cv = makeCanvas(W * S, H * S), g = cv.g, eaten = 0, tick = 0, over = false;
    var me = [W >> 1, H >> 1], bird = [W - 1, H - 1], cic = [], grass = {};
    for (var i = 0; i < 22; i++) { var gx = rnd(W - 2), gy = rnd(H); for (var a = 0; a < 3; a++) grass[(gx + a) + "," + gy] = 1; }
    function rc() { return [rnd(W), rnd(H)]; } for (i = 0; i < 5; i++) cic.push(rc());
    function draw() {
      g.fillStyle = "#e7f5dc"; g.fillRect(0, 0, W * S, H * S); g.font = "20px sans-serif"; g.textAlign = "center"; g.textBaseline = "middle";
      Object.keys(grass).forEach(function (k) { var p = k.split(",").map(Number); g.fillStyle = "#86c98a"; g.fillRect(p[0] * S, p[1] * S, S, S); g.fillText("🌿", p[0] * S + S / 2, p[1] * S + S / 2); });
      cic.forEach(function (c) { g.fillText("🦗", c[0] * S + S / 2, c[1] * S + S / 2); });
      g.fillText("🐦", bird[0] * S + S / 2, bird[1] * S + S / 2); g.fillText("🦗" === "" ? "" : "🪲", me[0] * S + S / 2, me[1] * S + S / 2);
      g.textBaseline = "alphabetic";
    }
    function mv(d) {
      if (over) return; var nx = clamp(me[0] + d[0], 0, W - 1), ny = clamp(me[1] + d[1], 0, H - 1); me = [nx, ny];
      cic.forEach(function (c, i) { if (c[0] === me[0] && c[1] === me[1]) { eaten++; cic[i] = rc(); } }); upd(); draw();
    }
    function upd() { if (eaten >= 10) { over = true; stop(); m.say("成功！吃到 10 隻蟬，也沒被黃雀抓到。捕食者自己也有天敵。", "ok"); } else m.say("你是螳螂 🪲：吃蟬 🦗（" + eaten + " / 10），躲開黃雀 🐦。躲進草叢 🌿 黃雀就看不到你。", "info"); }
    var dm = { U: [0, -1], D: [0, 1], L: [-1, 0], R: [1, 0] };
    chaseKey = function (e) { var d = { ArrowUp: "U", ArrowDown: "D", ArrowLeft: "L", ArrowRight: "R" }[e.key]; if (d) mv(dm[d]); };
    chaseTimer = setInterval(function () {
      if (over) return; tick++;
      if (tick % 3 === 0) cic.forEach(function (c) { c[0] = clamp(c[0] + rnd(3) - 1, 0, W - 1); c[1] = clamp(c[1] + rnd(3) - 1, 0, H - 1); });
      if (tick > 15 && tick % 2 === 0) {
        if (grass[me.join(",")]) { bird[0] = clamp(bird[0] + rnd(3) - 1, 0, W - 1); bird[1] = clamp(bird[1] + rnd(3) - 1, 0, H - 1); }
        else if (Math.abs(me[0] - bird[0]) >= Math.abs(me[1] - bird[1])) bird[0] += Math.sign(me[0] - bird[0]); else bird[1] += Math.sign(me[1] - bird[1]);
      }
      if (bird[0] === me[0] && bird[1] === me[1] && !grass[me.join(",")]) { over = true; stop(); m.say("黃雀吃掉了螳螂！「螳螂捕蟬，黃雀在後」。按「重新開始」再玩。", "bad"); }
      draw();
    }, 220);
    area.append(h("div", { class: "row c" }, cv.c), dpad(function (d) { mv(dm[d]); })); upd(); draw();
  }
  window.addEventListener("keydown", function (e) { if (chaseKey) chaseKey(e); });
  var fn = [chainQuiz, dietQuiz, chase];
  var tb = tabs(["食物鏈排序", "食性分類", "螳螂追逐戰"], function (i) { fn[i](); });
  root.append(tb.el, m.el, area, h("p", { class: "link" }, "食物鏈：植物 → 蟬 → 螳螂 → 黃雀。箭頭由被吃的指向吃它的。"));
  tb.sel(0);
});

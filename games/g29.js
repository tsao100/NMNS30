// 29 記憶100：記憶力測驗、腦的構成及功能
NMNS.register(29, function (root) {
  var m = msgBar(), area = h("div"), scores = { d: null, p: null, s: null };

  function digit() {
    area.innerHTML = ""; var L = 3, best = 2, box = h("div");
    async function round() {
      box.innerHTML = ""; var n = ""; for (var i = 0; i < L; i++) n += rnd(10);
      box.append(h("p", { class: "big" }, "測驗 1：數字記憶（" + L + " 位數）"), h("div", { class: "big mono", style: "font-size:2.4rem;text-align:center" }, n));
      await sleep(600 + L * 350); box.innerHTML = "";
      var inp = h("input", { type: "text", inputmode: "numeric", style: "font-size:1.3rem;width:9em", "aria-label": "剛才的數字" });
      var go = function () {
        if (inp.value === n) { best = L; L++; if (L > 9) return fin(); m.say("答對！", "ok"); round(); } else { m.say("答錯，剛才是 " + n + "。", "bad"); fin(); }
      };
      inp.addEventListener("keydown", function (e) { if (e.key === "Enter") go(); });
      box.append(h("p", { class: "big" }, "剛才的數字是？"), h("div", { class: "row" }, inp, btn("確定", go))); inp.focus();
    }
    function fin() { scores.d = Math.floor(33 * (best - 2) / 7); box.innerHTML = ""; box.append(h("p", { class: "big" }, "數字記憶：最長記住 " + best + " 位，得 " + scores.d + " / 33 分。"), btn("做下一項：翻牌配對", function () { tb.sel(1); })); m.say("完成第一項。", "ok"); }
    area.append(box); m.say("數字會短暫出現，記住後輸入。每次多一位。", "info"); round();
  }
  function pairs() {
    area.innerHTML = ""; var syms = shuffle(["🍎", "🍌", "🍇", "🍓", "🥝", "🍊", "🍉", "🍒", "🍎", "🍌", "🍇", "🍓", "🥝", "🍊", "🍉", "🍒"]), open = [], matched = {}, tries = 0, lock = false;
    var gr = h("div", { class: "cellgrid", style: "grid-template-columns:repeat(4,64px);justify-content:center;gap:6px" }), info = h("div", { class: "row" });
    function render() {
      gr.innerHTML = ""; syms.forEach(function (s, i) {
        var show = matched[i] || open.indexOf(i) >= 0;
        gr.append(h("button", { class: "cell", type: "button", "aria-label": show ? s : "蓋住的牌", style: "min-height:64px;font-size:1.8rem;border-radius:8px;" + (matched[i] ? "background:#bbf7d0" : show ? "background:#fef3c7" : "background:#94a3b8;color:#94a3b8"), onclick: function () { flip(i); } }, show ? s : "？"));
      });
      info.textContent = "嘗試次數 " + tries + "　（最少需要 8 次）";
    }
    async function flip(i) {
      if (lock || matched[i] || open.indexOf(i) >= 0) return; open.push(i); render();
      if (open.length === 2) {
        lock = true; tries++; var a = open[0], b = open[1];
        if (syms[a] === syms[b]) { matched[a] = matched[b] = 1; open = []; } else { render(); await sleep(900); open = []; }
        lock = false; render();
        if (Object.keys(matched).length === 16) { scores.p = clamp(34 - (tries - 8) * 3, 0, 34); m.say("配對完成！" + tries + " 次，得 " + scores.p + " / 34 分。", "ok"); area.append(btn("做下一項：燈光順序", function () { tb.sel(2); })); }
      }
    }
    area.append(info, gr); render(); m.say("找出 8 對相同的水果。次數越少分數越高。", "info");
  }
  function seq() {
    area.innerHTML = ""; var s = [], best = 0, box = h("div"), pads = [], busy = true, input = [];
    var COL = ["#ef4444", "#22c55e", "#3b82f6", "#eab308"], row = h("div", { class: "row c" });
    COL.forEach(function (c, i) { var b = h("button", { class: "btn", type: "button", style: "width:80px;height:80px;border-radius:14px;background:" + c + ";border-color:" + c + ";opacity:.45;font-size:1.4rem", "aria-label": "燈 " + (i + 1), onclick: function () { press(i); } }, i + 1); pads.push(b); row.append(b); });
    async function flash(i) { pads[i].style.opacity = 1; await sleep(420); pads[i].style.opacity = .45; await sleep(180); }
    async function play() { busy = true; input = []; s.push(rnd(4)); box.textContent = "第 " + s.length + " 關：看燈的順序…"; await sleep(500); for (var k = 0; k < s.length; k++) await flash(s[k]); box.textContent = "換你了，照順序按燈（共 " + s.length + " 個）"; busy = false; }
    function press(i) {
      if (busy) return; flash(i); input.push(i);
      if (input[input.length - 1] !== s[input.length - 1]) { busy = true; fin(); return; }
      if (input.length === s.length) { best = s.length; if (best >= 10) { fin(); return; } m.say("答對！", "ok"); busy = true; setTimeout(play, 800); }
    }
    function fin() { scores.s = Math.floor(33 * best / 10); box.textContent = "最長記住 " + best + " 個，得 " + scores.s + " / 33 分。"; m.say("燈光順序完成。", "ok"); area.append(btn("看總成績", function () { tb.sel(3); })); }
    area.append(box, row); m.say("燈會依序亮起，記住順序再按一次。", "info"); play();
  }
  function total() {
    area.innerHTML = ""; var d = scores.d, p = scores.p, s = scores.s, done = [d, p, s].every(function (v) { return v != null; }), tot = (d || 0) + (p || 0) + (s || 0);
    area.append(h("table", { class: "t" }, h("tr", {}, h("th", {}, "項目"), h("th", {}, "得分")), h("tr", {}, h("td", {}, "數字記憶"), h("td", {}, d == null ? "尚未測驗" : d + " / 33")), h("tr", {}, h("td", {}, "翻牌配對"), h("td", {}, p == null ? "尚未測驗" : p + " / 34")), h("tr", {}, h("td", {}, "燈光順序"), h("td", {}, s == null ? "尚未測驗" : s + " / 33")), h("tr", {}, h("th", {}, "總分"), h("th", {}, tot + " / 100"))),
      h("p", { class: "big" }, done ? (tot >= 85 ? "記憶力超強！" : tot >= 65 ? "記憶力良好。" : tot >= 40 ? "普通，多練習會進步。" : "繼續訓練，記憶像肌肉一樣會越練越強。") : "三項都做完才有完整評語。"),
      h("p", { class: "link" }, "記憶小技巧：把數字分組（例如 3-3-4）、大聲複誦、把東西連成故事、睡飽覺——睡眠能幫海馬迴把新記憶存起來。"));
    m.say("你的記憶分數。", "info");
  }
  function brain() {
    area.innerHTML = ""; var P = [
      ["額葉", "計畫、做決定、說話、控制行為，是思考與個性的中心。", "#fca5a5"], ["頂葉", "感覺觸摸、疼痛、冷熱，知道身體各部位的位置。", "#fcd34d"], ["枕葉", "視覺：把眼睛傳來的訊號變成我們看到的畫面。", "#a5b4fc"],
      ["顳葉", "聽覺、理解語言，也負責儲存記憶。", "#86efac"], ["小腦", "維持平衡，讓動作順暢協調（例如騎腳踏車）。", "#f9a8d4"], ["腦幹", "控制呼吸、心跳與睡眠，連接大腦和脊髓。", "#cbd5e1"], ["海馬迴", "藏在顳葉深處，把短期記憶變成長期記憶。", "#f97316"]
    ];
    var cv = makeCanvas(520, 330), g = cv.g, info = h("div", { class: "msg info" }, "點腦的各個部位。（側面圖，左邊是前方）"), sel = -1;
    function ell(cx, cy, rx, ry, rot, col, sel_) { g.save(); g.translate(cx, cy); g.rotate(rot); g.beginPath(); g.ellipse(0, 0, rx, ry, 0, 0, 7); g.fillStyle = col; g.fill(); g.lineWidth = sel_ ? 4 : 1.5; g.strokeStyle = sel_ ? "#111" : "#6b7280"; g.stroke(); g.restore(); }
    var shapes = [[150, 130, 95, 85, 0], [270, 90, 75, 55, 0], [390, 140, 65, 70, 0], [215, 205, 95, 38, 0], [380, 250, 60, 40, 0], [300, 290, 20, 55, .35], [225, 195, 40, 14, 0]];
    function paint() {
      g.fillStyle = "#fff"; g.fillRect(0, 0, 520, 330);
      var order = [0, 1, 2, 3, 4, 5, 6]; order.forEach(function (i) { var s = shapes[i]; ell(s[0], s[1], s[2], s[3], s[4], P[i][2], sel === i); });
      g.fillStyle = "#111"; g.font = "bold 13px sans-serif"; g.textAlign = "center"; order.forEach(function (i) { var s = shapes[i]; g.fillText(P[i][0], s[0], s[1] + 4); });
    }
    cv.c.addEventListener("click", function (e) {
      var p = canvasPos(cv.c, e), hit = -1;
      for (var i = 6; i >= 0; i--) { var s = shapes[i], dx = p.x - s[0], dy = p.y - s[1], c = Math.cos(-s[4]), sn = Math.sin(-s[4]), rx = dx * c - dy * sn, ry = dx * sn + dy * c; if ((rx * rx) / (s[2] * s[2]) + (ry * ry) / (s[3] * s[3]) <= 1) { hit = i; break; } }
      if (hit >= 0) { sel = hit; paint(); info.innerHTML = "<b>" + P[hit][0] + "</b>：" + P[hit][1]; }
    });
    paint(); area.append(cv.c, info); m.say("腦的構造與功能。", "info");
  }
  var fn = [digit, pairs, seq, total, brain];
  var tb = tabs(["①數字記憶", "②翻牌配對", "③燈光順序", "總成績", "腦的構造"], function (i) { fn[i](); });
  root.append(tb.el, m.el, area); tb.sel(0);
});

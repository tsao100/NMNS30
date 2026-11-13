// 21 翹翹板：槓桿平衡原理
NMNS.register(21, function (root) {
  var W = 640, Hh = 300, PX = 55, cv = makeCanvas(W, Hh), g = cv.g, m = msgBar();
  var lvl = 0, TOTAL = 5, fixed, user, tray, selW = null, hidden = null, ansBox = h("div"), trayBox = h("div", { class: "row" }), info = h("div", { class: "row" }), solved = false;

  function torque(list) { return list.reduce(function (s, o) { return s + o.w * o.p; }, 0); }
  function makeLevel() {
    var tries = 0; user = {}; selW = null; solved = false; hidden = null; ansBox.innerHTML = "";
    while (tries++ < 500) {
      if (lvl < 3) {
        var k = lvl === 0 ? 1 : 2, T = 0, sol = [], ps = shuffle([1, 2, 3, 4, 5]);
        for (var i = 0; i < k; i++) { var w = 1 + rnd(6); sol.push(w); T += w * ps[i]; }
        var cands = []; for (var d = 1; d <= 5; d++) if (T % d === 0 && T / d <= 12) cands.push([T / d, d]);
        if (!cands.length || (k === 1 && cands.length === 0)) continue;
        var f = pick(cands); fixed = [{ w: f[0], p: -f[1] }]; tray = sol.concat([1 + rnd(6), 1 + rnd(6)]);
      } else {
        var mm = 1 + rnd(6), dd = 1 + rnd(5); hidden = { w: mm, p: -dd }; fixed = [hidden]; tray = [mm, 1 + rnd(6), 1 + rnd(6), 1 + rnd(6)];
        if (lvl === 4) { var extra = { w: 1 + rnd(4), p: -(1 + rnd(5)) }; while (extra.p === hidden.p) extra.p = -(1 + rnd(5)); fixed.push(extra); tray = tray.concat([mm * dd > 5 ? 3 : 2]); }
      }
      tray = shuffle(tray).map(function (w, i) { return { w: w, id: i, used: false }; });
      break;
    }
    draw(); renderTray(); upd();
    m.say(lvl >= 3 ? "第 " + (lvl + 1) + " 關：左邊有「？」神秘重物。用砝碼讓翹翹板平衡，再算出它有幾公斤。" : "第 " + (lvl + 1) + " 關：選一個砝碼，點橫桿上的位置放下，讓兩邊力矩相等。", "info");
  }
  function userList() { return Object.keys(user).map(function (p) { return { w: user[p].w, p: +p }; }); }
  function allList() { return fixed.concat(userList()); }
  function upd() {
    var L = 0, R = 0; allList().forEach(function (o) { if (o.p < 0) L += o.w * -o.p; else R += o.w * o.p; });
    var hid = hidden ? "（含神秘重物，不顯示）" : "";
    var Ls = hidden ? "？" : L; if (hidden) { L = fixed.filter(function (o) { return o !== hidden && o.p < 0; }).reduce(function (s, o) { return s + o.w * -o.p; }, 0) + userList().filter(function (o) { return o.p < 0; }).reduce(function (s, o) { return s + o.w * -o.p; }, 0); Ls = "？ + " + L; }
    info.textContent = "左邊力矩 " + Ls + "　右邊力矩 " + R + "　（力矩 = 重量 × 離支點距離）" + hid;
    draw();
    var bal = torque(allList()) === 0 && userList().length > 0;
    if (bal && !solved) {
      if (hidden) {
        ansBox.innerHTML = ""; var inp = h("input", { type: "number", min: 1, max: 12, "aria-label": "神秘重物重量" });
        ansBox.append(h("div", { class: "row" }, "平衡了！神秘重物是幾公斤？", inp, btn("答", function () {
          if (+inp.value === hidden.w) { solved = true; ansBox.innerHTML = ""; done(); } else m.say("不對，再用力矩算一次：重物重量 × 距離 = 砝碼力矩總和。", "bad");
        })));
      } else { solved = true; done(); }
    }
  }
  function done() {
    m.say("答對！翹翹板平衡 " + (hidden ? "，神秘重物是 " + hidden.w + " 公斤。" : "。"), "ok");
    ansBox.append(lvl + 1 < TOTAL ? btn("下一關", function () { lvl++; makeLevel(); }) : h("div", { class: "big" }, "全部通關！槓桿原理：左力矩 = 右力矩。"));
  }
  function renderTray() {
    trayBox.innerHTML = "砝碼：";
    tray.forEach(function (t) {
      trayBox.append(btn(t.w + " kg", function () { if (!t.used) { selW = t; renderTray(); } }, "choice" + (selW === t ? " sel" : "")));
      trayBox.lastChild.disabled = t.used;
    });
  }
  function draw() {
    g.fillStyle = "#fff"; g.fillRect(0, 0, W, Hh);
    var tq = hidden || !fixed.length ? torque(allList()) : torque(allList()), ang = clamp(tq * 0.0045, -0.3, 0.3);
    g.fillStyle = "#6b7280"; g.beginPath(); g.moveTo(320, 190); g.lineTo(290, 280); g.lineTo(350, 280); g.fill();
    g.save(); g.translate(320, 190); g.rotate(ang);
    g.fillStyle = "#a16207"; g.fillRect(-300, -6, 600, 12);
    g.fillStyle = "#555"; g.font = "11px sans-serif"; g.textAlign = "center";
    for (var p = -5; p <= 5; p++) { g.fillRect(p * PX - 1, -6, 2, 12); if (p) g.fillText(Math.abs(p), p * PX, 20); }
    function box(o, hid, mine) {
      var sz = 16 + o.w * 3; g.fillStyle = hid ? "#7c3aed" : mine ? "#2b6cb0" : "#c2410c"; g.fillRect(o.p * PX - sz / 2, -6 - sz, sz, sz);
      g.fillStyle = "#fff"; g.font = "bold 13px sans-serif"; g.fillText(hid ? "？" : o.w, o.p * PX, -6 - sz / 2 + 5);
    }
    fixed.forEach(function (o) { box(o, o === hidden, false); }); userList().forEach(function (o) { box(o, false, true); });
    g.restore();
    g.fillStyle = "#999"; g.font = "12px sans-serif"; g.fillText("支點", 320, 296);
  }
  cv.c.addEventListener("click", function (e) {
    if (solved) return; var pt = canvasPos(cv.c, e), p = Math.round((pt.x - 320) / PX);
    if (p === 0 || Math.abs(p) > 5) return;
    if (fixed.some(function (o) { return o.p === p; })) { m.say("這個位置已經有重物了。", "bad"); return; }
    if (user[p]) { user[p].t.used = false; delete user[p]; renderTray(); upd(); return; }
    if (!selW) { m.say("先選一個砝碼。", "bad"); return; }
    user[p] = { w: selW.w, t: selW }; selW.used = true; selW = null; renderTray(); upd();
  });
  root.append(m.el, info, trayBox, cv.c, ansBox, h("p", { class: "link" }, "槓桿平衡：左邊（重量×距離）的總和 = 右邊（重量×距離）的總和。點已放下的砝碼可拿回來。"));
  makeLevel();
});

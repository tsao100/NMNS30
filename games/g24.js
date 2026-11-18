// 24 雷射迷宮：移植自 LASER.BAS（1982 年 Apple II《Lazer Maze》，James Spain）
// 規則、畫面座標、計分都依 QBasic 原程式；畫面是 640×480 的 SCREEN 12 模擬。
NMNS.register(24, function (root) {
  var GX0 = 160, GY0 = 56, CW = 32, NSHOT = 20;
  var EGA = ["#000000", "#0000aa", "#00aa00", "#00aaaa", "#aa0000", "#aa00aa", "#aa5500", "#aaaaaa", "#555555", "#5555ff", "#55ff55", "#55ffff", "#ff5555", "#ff55ff", "#ffff55", "#ffffff"];
  var CT = [14, 10, 12, 11, 13, 9, 15, 6, 2, 4, 3, 5, 7, 1];
  var cv = makeCanvas(640, 480), g = cv.g;
  cv.c.style.background = "#000"; cv.c.style.cursor = "pointer"; cv.c.style.touchAction = "manipulation";
  var help = h("div", { class: "edu", style: "margin-top:0" },
    h("b", {}, "玩法（依原版 Lazer Maze）"),
    "10×10 的盒子裡藏著斜放的反射鏡（╱ ╲）。盒子四周有 10～49 號出入口：10–19 在上方（左到右）、20–29 在左邊（上到下）、30–39 在下方、40–49 在右邊。士兵（閃爍的小人）從某個號碼發射雷射，你要判斷光線反射後會從哪一個號碼出來，直接點那個號碼（或輸入兩位數字）。答對外星人被擊中，答錯外星人會丟炸彈。每局 20 發，每個號碼只會用一次；得分看反射次數與回答速度。",
    h("p", { style: "margin:8px 0 0" }, h("b", {}, "快速得分："), "作答時按 ", h("kbd", {}, "A")," 鍵（或點右側「自動解答」），電腦會用最快的速度答完這一局剩下的所有光束，並自動加快動畫。用了自動解答的成績不會登錄到高分榜。"));
  var S, keys = [], MX = -1, MY = -1, CLK = 0, CLKX = 0, CLKY = 0, actx = null;

  function reset() {
    S = { scrn: 0, showmenu: 0, soundon: 1, maz: [], seen: [], used: [], ucol: [], px: [], py: [], np: 0, hci: [], hcj: [], nh: 0, bb: 0, exitp: 0,
      beams: [], live: [], fx: [], btns: [], msg: ["", "", ""], mcol: [15, 15, 15], endview: 0, score: 7000, hi: 0, refl: 20, lvl: "初學者", auto: 0, autoUsed: 0, showauto: 0,
      miss: 0, shotno: 0, gameok: 1, soldv: 0, soldx: 0, soldy: 0, alv: 0, alx: 0, aly: 0, hit: 0, hovp: 0, quittut: 0, title: "" };
    for (var i = 0; i < 10; i++) { S.maz.push(Array(10).fill(0)); S.seen.push(Array(10).fill(0)); }
    for (var p = 10; p < 50; p++) { S.used[p] = 0; S.ucol[p] = 0; }
    S.geo = {};
    for (p = 10; p < 50; p++) {
      var s = Math.floor((p - 10) / 10), k = (p - 10) % 10, G = {};
      if (s === 0) { G.lx = 168 + 32 * k; G.ly = 32; G.sx = G.lx + 8; G.sy = 14; G.ex = G.sx; G.ey = 27; G.z = [GX0 + 32 * k, 0, GX0 + 32 * k + 31, GY0 - 1]; }
      else if (s === 1) { G.lx = 128; G.ly = 64 + 32 * k; G.sx = 100; G.sy = G.ly + 8; G.ex = 114; G.ey = G.sy; G.z = [84, GY0 + 32 * k, GX0 - 1, GY0 + 32 * k + 31]; }
      else if (s === 2) { G.lx = 168 + 32 * k; G.ly = 384; G.sx = G.lx + 8; G.sy = 414; G.ex = G.sx; G.ey = 401; G.z = [GX0 + 32 * k, GY0 + 321, GX0 + 32 * k + 31, 426]; }
      else { G.lx = 496; G.ly = 64 + 32 * k; G.sx = 540; G.sy = G.ly + 8; G.ex = 526; G.ey = G.sy; G.z = [GX0 + 321, GY0 + 32 * k, 549, GY0 + 32 * k + 31]; }
      S.geo[p] = G;
    }
  }

  // ---------- 繪圖基本動作 ----------
  function col(c) { return EGA[c]; }
  function bf(x1, y1, x2, y2, c) { g.fillStyle = col(c); g.fillRect(Math.min(x1, x2), Math.min(y1, y2), Math.abs(x2 - x1) + 1, Math.abs(y2 - y1) + 1); }
  function box(x1, y1, x2, y2, c) { g.strokeStyle = col(c); g.lineWidth = 1; g.strokeRect(Math.min(x1, x2) + .5, Math.min(y1, y2) + .5, Math.abs(x2 - x1), Math.abs(y2 - y1)); }
  function ln(x1, y1, x2, y2, c, dash) { g.strokeStyle = col(c); g.lineWidth = 1; g.setLineDash(dash ? [4, 4] : []); g.beginPath(); g.moveTo(x1 + .5, y1 + .5); g.lineTo(x2 + .5, y2 + .5); g.stroke(); g.setLineDash([]); }
  function ps(x, y, c) { bf(x, y, x, y, c); }
  function disc(x, y, r, c) { g.fillStyle = col(c); g.beginPath(); g.arc(x + .5, y + .5, r, 0, 7); g.fill(); }
  var WF = "bold 14px 'Noto Sans TC','Microsoft JhengHei','PingFang TC','Heiti TC',sans-serif", AF = "13px 'Courier New', monospace";
  function dw(s) { var n = 0; for (var i = 0; i < s.length; i++) n += s.charCodeAt(i) > 255 ? 2 : 1; return n; }
  function clip(s, m) { var n = 0, o = ""; for (var i = 0; i < s.length; i++) { var w = s.charCodeAt(i) > 255 ? 2 : 1; if (n + w > m) break; n += w; o += s[i]; } return o; }
  function txt(c0, r0, s, c) {
    g.fillStyle = col(c); g.textBaseline = "alphabetic"; var x = (c0 - 1) * 8;
    for (var i = 0; i < s.length; i++) { var wide = s.charCodeAt(i) > 255; g.font = wide ? WF : AF; g.fillText(s[i], x, (r0 - 1) * 16 + 12); x += wide ? 16 : 8; }
  }
  function ctext(r, s, c) { txt(Math.floor((80 - dw(s)) / 2) + 1, r, s, c); }
  function seg(x1, y1, x2, y2, c, dash) { if (dash) ln(x1, y1, x2, y2, c, true); else { ln(x1, y1, x2, y2, c); ln(x1 + 1, y1 + 1, x2 + 1, y2 + 1, c); } }
  function soldier(cx, cy) {
    bf(cx - 6, cy - 11, cx + 6, cy - 8, 2); bf(cx - 7, cy - 8, cx + 7, cy - 7, 10); bf(cx - 5, cy - 6, cx + 5, cy - 1, 14); ps(cx - 2, cy - 4, 0); ps(cx + 2, cy - 4, 0);
    bf(cx - 6, cy, cx + 6, cy + 7, 2); ln(cx - 6, cy + 4, cx + 6, cy + 4, 6); bf(cx - 10, cy, cx - 8, cy + 6, 2); bf(cx + 8, cy + 1, cx + 10, cy + 5, 2); ln(cx + 8, cy + 3, cx + 11, cy + 3, 7);
    bf(cx - 5, cy + 8, cx - 2, cy + 11, 10); bf(cx + 2, cy + 8, cx + 5, cy + 11, 10);
  }
  function alien(cx, cy) {
    disc(cx, cy - 1, 9, 10); bf(cx - 7, cy - 4, cx - 2, cy + 1, 0); bf(cx + 2, cy - 4, cx + 7, cy + 1, 0); ps(cx - 5, cy - 2, 15); ps(cx + 5, cy - 2, 15);
    ln(cx - 4, cy - 9, cx - 6, cy - 11, 10); ln(cx + 4, cy - 9, cx + 6, cy - 11, 10); ps(cx - 6, cy - 11, 12); ps(cx + 6, cy - 11, 12);
    bf(cx - 3, cy + 8, cx + 3, cy + 11, 2); bf(cx - 8, cy + 9, cx - 6, cy + 11, 2); bf(cx + 6, cy + 9, cx + 8, cy + 11, 2);
  }
  function mirror(i, j, kind, c) {
    var x = GX0 + i * CW, y = GY0 + j * CW;
    if (kind === 1) { ln(x + 6, y + 26, x + 26, y + 6, c); ln(x + 7, y + 26, x + 27, y + 6, c); } else { ln(x + 6, y + 6, x + 26, y + 26, c); ln(x + 7, y + 6, x + 27, y + 26, c); }
  }
  function label(p, hl) {
    var G = S.geo[p], x = G.lx, y = G.ly, bc, fg;
    bf(x - 3, y - 1, x + 18, y + 16, 0);
    if (hl) { box(x - 3, y - 1, x + 18, y + 16, 15); box(x - 2, y, x + 17, y + 15, 14); fg = 15; }
    else { if (!S.ucol[p]) { bc = 8; fg = 7; } else { bc = S.ucol[p]; fg = S.ucol[p]; } box(x - 3, y - 1, x + 18, y + 16, bc); }
    txt(Math.floor(x / 8) + 1, Math.floor(y / 16) + 1, String(p), fg);
  }
  function btnXY(x, y, w, hh, t, hov) {
    bf(x, y, x + w - 1, y + hh - 1, 0); var fg;
    if (hov) { box(x, y, x + w - 1, y + hh - 1, 15); box(x + 1, y + 1, x + w - 2, y + hh - 2, 9); fg = 14; } else { box(x, y, x + w - 1, y + hh - 1, 11); fg = 15; }
    txt(Math.floor((x + Math.floor((w - 8 * dw(t)) / 2)) / 8) + 1, Math.floor((y + Math.floor((hh - 16) / 2)) / 16) + 1, t, fg);
  }
  function side() { btnXY(556, 64, 80, 24, S.soundon ? "音效：開" : "音效：關", 0); if (S.showmenu) btnXY(556, 96, 80, 24, "選單", 0); if (S.showauto) btnXY(556, 128, 80, 24, S.auto ? "自動中…" : "自動解答", 0); }
  function stat(r, l, v, c) { txt(1, r, l, 8); txt(1, r + 1, clip(String(v), 11), c); }

  function render() {
    bf(0, 0, 639, 479, 0);
    if (S.scrn === 0) {
      ctext(2, "雷 射 迷 宮   LAZER MAZE", 14); ctext(4, "考驗眼力與反應的遊戲", 11); ctext(6, "重製自 James Spain 於 1982 年的 Apple II 遊戲《Lazer Maze》", 7);
      for (var k = 0; k < 2; k++) { ln(104, 146 + k, 200, 146 + k, 12); ln(200 + k, 146, 200 + k, 121, 12); ln(200, 121 + k, 440, 121 + k, 12); ln(440 + k, 121, 440 + k, 146, 12); ln(440, 146 + k, 536, 146 + k, 12); }
      ln(192, 158, 208, 142, 15); ln(192, 133, 208, 117, 15); ln(432, 117, 448, 133, 15); ln(432, 142, 448, 158, 15);
      soldier(90, 146); alien(550, 146); ctext(12, "你想做什麼？", 15); ctext(24, "滑鼠：點按鈕、點出口號碼作答　鍵盤：輸入兩位數字", 7); ctext(25, "F2＝音效開關　ESC＝離開　A＝自動解答", 8);
    } else if (S.scrn === 2) {
      ctext(8, "雷 射 迷 宮   LAZER MAZE", 14); ctext(12, "你目前的等級：" + S.lvl, 15); ctext(14, "盒內有 " + S.refl + " 面反射鏡", 15); ctext(17, "每局有 " + NSHOT + " 道光束", 7);
    } else {
      txt(1, 1, "雷射迷宮", 14);
      box(GX0 - 1, GY0 - 1, GX0 + 320, GY0 + 320, 15);
      for (var i = 1; i < 10; i++) { ln(GX0 + i * CW, GY0, GX0 + i * CW, GY0 + 319, 8); ln(GX0, GY0 + i * CW, GX0 + 319, GY0 + i * CW, 8); }
      S.beams.forEach(function (b) { for (var n = 0; n < b.pts.length - 1; n++) seg(b.pts[n][0], b.pts[n][1], b.pts[n + 1][0], b.pts[n + 1][1], b.c, b.dash); });
      S.live.forEach(function (l) { seg(l[0], l[1], l[2], l[3], l[4], l[5]); });
      for (var a = 0; a < 10; a++) for (var b2 = 0; b2 < 10; b2++) if (S.maz[a][b2]) mirror(a, b2, S.maz[a][b2], S.endview && !S.seen[a][b2] ? 14 : 15);
      for (var p = 10; p < 50; p++) label(p, p === S.hovp);
      if (S.soldv) soldier(S.soldx, S.soldy); if (S.alv) alien(S.alx, S.aly);
      stat(4, "第幾發", S.shotno + "/" + NSHOT, 14); stat(7, "得分", S.score, 15); stat(10, "最高分", S.hi, 11); stat(13, "反射鏡", S.refl, 10); stat(16, "失誤", S.miss, S.miss > 0 ? 12 : 7);
      box(4, 428, 635, 479, 8);
      for (var l = 0; l < 3; l++) { txt(2, 28 + l, clip(S.msg[l], 76), S.mcol[l]); }
    }
    S.fx.forEach(function (f) { f(); });
    side();
    S.btns.forEach(function (b, i) { btnXY(b.x, b.y, b.w, b.h, b.t, i === S.hovb); });
  }

  // ---------- 輸入與聲音 ----------
  function pt(e) { var r = cv.c.getBoundingClientRect(); return [(e.clientX - r.left) * 640 / r.width, (e.clientY - r.top) * 480 / r.height]; }
  cv.c.addEventListener("pointerdown", function (e) { var p = pt(e); CLK = 1; CLKX = p[0]; CLKY = p[1]; MX = p[0]; MY = p[1]; });
  cv.c.addEventListener("pointermove", function (e) { var p = pt(e); MX = p[0]; MY = p[1]; });
  window.addEventListener("keydown", function (e) {
    if (e.ctrlKey || e.metaKey || e.altKey) return;
    var k = e.key; if (k === "Enter") k = "\r"; else if (k === "Escape") k = "\x1b"; else if (k === "Backspace") k = "\b"; else if (k === "F2") { e.preventDefault(); S.soundon = 1 - S.soundon; render(); return; } else if (k.length !== 1) return;
    keys.push(k); if (k === "\b" || k === " ") e.preventDefault();
  });
  function getKey() { return keys.length ? keys.shift() : ""; }
  function flushIn() { CLK = 0; keys.length = 0; }
  function zz(ms) { return sleep(S.auto ? Math.min(ms, 20) : ms); }
  async function snd(f, t) {
    if (!S.soundon || S.auto) return; var dur = t / 18.2 * 1000;
    try {
      actx = actx || new (window.AudioContext || window.webkitAudioContext)(); if (actx.state === "suspended") actx.resume();
      var o = actx.createOscillator(), gn = actx.createGain(); o.type = "square"; o.frequency.value = Math.max(37, Math.min(8000, f)); gn.gain.value = 0.03; o.connect(gn); gn.connect(actx.destination); o.start(); o.stop(actx.currentTime + dur / 1000);
    } catch (e) { }
    await sleep(dur);
  }
  function msg(l, t, c) { S.msg[l - 1] = t; S.mcol[l - 1] = c; render(); }
  function statusReset() { for (var i = 1; i <= 3; i++) { S.msg[i - 1] = ""; S.mcol[i - 1] = 15; } }
  function addBtn(x, y, w, hh, t, k1, k2) { S.btns.push({ x: x, y: y, w: w, h: hh, t: t, k1: k1, k2: k2 || 0 }); }
  function clearBtns() { S.btns = []; S.hovb = -1; }
  function sideHit(x, y) {
    if (x >= 556 && x < 636 && y >= 64 && y < 88) { S.soundon = 1 - S.soundon; render(); return 1; }
    if (S.showmenu && x >= 556 && x < 636 && y >= 96 && y < 120) return 2;
    if (S.showauto && x >= 556 && x < 636 && y >= 128 && y < 152) return 3; return 0;
  }
  function portAt(x, y) { var r = 0; for (var p = 10; p < 50; p++) { var z = S.geo[p].z; if (x >= z[0] && x <= z[2] && y >= z[1] && y <= z[3]) r = p; } return r; }
  async function waitChoice() {
    S.hovb = -1; render(); flushIn(); var hv = -1;
    while (true) {
      if (CLK) {
        CLK = 0; var s = sideHit(CLKX, CLKY); if (s === 2) return -1;
        if (s === 0) for (var i = 0; i < S.btns.length; i++) { var b = S.btns[i]; if (CLKX >= b.x && CLKX < b.x + b.w && CLKY >= b.y && CLKY < b.y + b.h) return i + 1; }
      }
      var k = getKey();
      if (k) {
        var kc = k.charCodeAt(0); if (kc === 27) return -1; var u = k.toUpperCase().charCodeAt(0);
        for (i = 0; i < S.btns.length; i++) if (S.btns[i].k1 === u || S.btns[i].k2 === u) return i + 1;
      }
      var hh = -1; S.btns.forEach(function (b, i) { if (MX >= b.x && MX < b.x + b.w && MY >= b.y && MY < b.y + b.h) hh = i; });
      if (hh !== hv) { hv = hh; S.hovb = hh; render(); }
      await sleep(15);
    }
  }

  // ---------- 遊戲邏輯（依 BuildMaze / Trace） ----------
  function buildMaze(n) {
    for (var i = 0; i < 10; i++) for (var j = 0; j < 10; j++) S.maz[i][j] = 0;
    var cnt = 0; while (cnt < n) { var a = rnd(10), b = rnd(10); if (S.maz[a][b] === 0) { S.maz[a][b] = 1 + rnd(2); cnt++; } }
  }
  function trace(p) {
    var s = Math.floor((p - 10) / 10), k = (p - 10) % 10, i, j, di, dj;
    if (s === 0) { i = k; j = 0; di = 0; dj = 1; } else if (s === 1) { i = 0; j = k; di = 1; dj = 0; } else if (s === 2) { i = k; j = 9; di = 0; dj = -1; } else { i = 9; j = k; di = -1; dj = 0; }
    S.px = [S.geo[p].ex]; S.py = [S.geo[p].ey]; S.np = 1; S.bb = 0; S.nh = 0; S.hci = []; S.hcj = [];
    while (i >= 0 && i <= 9 && j >= 0 && j <= 9) {
      if (S.maz[i][j]) {
        S.bb++; S.hci.push(i); S.hcj.push(j); S.nh++; S.px.push(GX0 + i * CW + 16); S.py.push(GY0 + j * CW + 16); S.np++;
        var t = di; if (S.maz[i][j] === 1) { di = -dj; dj = -t; } else { di = dj; dj = t; }
      }
      i += di; j += dj;
    }
    var ex = j < 0 ? 10 + i : i < 0 ? 20 + j : j > 9 ? 30 + i : 40 + j;
    S.exitp = ex; S.px.push(S.geo[ex].ex); S.py.push(S.geo[ex].ey); S.np++; S.bb++;
  }
  window.__laser = { trace: function (p) { trace(p); return S.exitp; }, S: function () { return S; } };

  async function explode(x, y) {
    S.fx.push(function () { disc(x, y, 5, 14); }); render(); await snd(120, 1);
    S.fx.push(function () { disc(x, y, 12, 12); disc(x, y, 6, 14); }); render(); await snd(90, 1);
    S.fx.push(function () { for (var k = 0; k < 8; k++) { var a = k * Math.PI / 4; ln(x, y, x + Math.round(20 * Math.cos(a)), y + Math.round(20 * Math.sin(a)), 14); } disc(x, y, 9, 4); disc(x, y, 4, 14); }); render();
    for (var n = 0; n < 6; n++) await snd(60 + rnd(300), 1);
    await zz(200);
  }
  async function throwBomb(x1, y1, x2, y2) {
    var dx = x2 - x1, dy = y2 - y1, ns = Math.max(1, Math.floor(Math.hypot(dx, dy) / 14));
    for (var n = 0; n <= ns; n++) {
      var bx = x1 + Math.round(dx * n / ns), by = y1 + Math.round(dy * n / ns);
      S.fx = [function () { disc(bx, by, 6, 7); ln(bx, by - 6, bx + 4, by - 10, 14); ps(bx + 4, by - 10, 12); }]; render(); await snd(300 + (ns - n) * 15, 1); await zz(20);
    }
    S.fx = [];
  }
  async function doShot(p, gs, c, dash) {
    var s = Math.floor((p - 10) / 10), G = S.geo[gs], ax = G.sx, ay = G.sy;
    if (gs === p) { if (s === 0 || s === 2) ax += 36; else ay += 36; }
    S.soldx = S.geo[p].sx; S.soldy = S.geo[p].sy; S.soldv = 1; render();
    for (var f = 3000; f >= 600; f -= 400) await snd(f, 1);
    S.alx = ax; S.aly = ay; S.alv = 1; S.live = []; render();
    for (var n = 0; n < S.np - 1; n++) {
      var x1 = S.px[n], y1 = S.py[n], x2 = S.px[n + 1], y2 = S.py[n + 1], len = Math.hypot(x2 - x1, y2 - y1), steps = Math.floor(len / 16) + 1, px0 = x1, py0 = y1;
      for (var t = 1; t <= steps; t++) {
        var nx = x1 + Math.round((x2 - x1) * t / steps), ny = y1 + Math.round((y2 - y1) * t / steps);
        S.live.push([px0, py0, nx, ny, c, dash]); render(); px0 = nx; py0 = ny; await zz(10);
      }
      if (n < S.np - 2) await snd(1500, 1);
    }
    if (gs === S.exitp) { S.hit = 1; await explode(ax, ay); } else { S.hit = 0; await throwBomb(ax, ay, S.geo[p].sx, S.geo[p].sy); await explode(S.geo[p].sx, S.geo[p].sy); }
    await zz(500);
    S.beams.push({ pts: S.px.map(function (x, i) { return [x, S.py[i]]; }), c: c, dash: dash });
    S.live = []; S.fx = []; S.soldv = 0; S.alv = 0; render();
  }
  async function readGuess(p) {
    S.soldx = S.geo[p].sx; S.soldy = S.geo[p].sy; S.soldv = 1; flushIn(); clearBtns();
    var pr = "雷射 " + p + " 號光束的出口是幾號？ "; msg(1, pr, 15); msg(2, "點選出口號碼，或輸入兩位數字　（按 A 自動解答）", 7);
    S.hovp = 0; var d = "", res = 0, done = 0, t0 = performance.now(), lb = performance.now();
    function goAuto() { S.auto = 1; S.autoUsed = 1; res = S.exitp; done = 1; }
    if (S.auto) { goAuto(); msg(1, "自動解答中…雷射 " + p + " 號 → " + res + " 號", 14); S.soldv = 1; S.tk = 11; await zz(30); return res; }
    while (!done) {
      if (CLK) { CLK = 0; var sh = sideHit(CLKX, CLKY); if (sh === 2) { res = -1; done = 1; } else if (sh === 3) goAuto(); else if (sh === 0) { var q = portAt(CLKX, CLKY); if (q > 0) { res = q; done = 1; } } }
      if (!done) {
        var k = getKey();
        if (k) {
          var kc = k.charCodeAt(0);
          if (kc === 27) { res = -1; done = 1; }
          else if (k === "a" || k === "A") goAuto();
          else if (kc === 8) { d = ""; msg(1, pr, 15); }
          else if (kc >= 48 && kc <= 57) {
            if (d === "") { if (kc >= 49 && kc <= 52) d = k; else await snd(800, 4); } else d += k;
            msg(1, pr + d, 15); if (d.length === 2) { res = parseInt(d, 10); done = 1; }
          } else await snd(800, 4);
        }
      }
      if (!done) {
        var q2 = portAt(MX, MY); if (q2 !== S.hovp) { S.hovp = q2; render(); }
        if (performance.now() - lb > 300) { S.soldv = 1 - S.soldv; lb = performance.now(); render(); }
      }
      await sleep(15);
    }
    S.hovp = 0; S.soldv = 1; render();
    if (S.auto) { S.tk = 11; return res; }
    var el = (performance.now() - t0) / 1000; if (el > 3000) el = 3000; S.tk = Math.floor(el * 10) + 1; return res;
  }
  function resetBoardView() { S.beams = []; S.live = []; S.fx = []; S.soldv = 0; S.alv = 0; S.endview = 0; for (var p = 10; p < 50; p++) { S.used[p] = 0; S.ucol[p] = 0; } S.scrn = 3; S.showmenu = 1; S.showauto = 1; clearBtns(); render(); }

  async function levelPage() {
    S.scrn = 2; S.showmenu = 1; statusReset(); clearBtns(); addBtn(270, 296, 100, 32, "開始", 13); var r = await waitChoice(); clearBtns(); if (r < 0) S.gameok = 0;
  }
  async function playGame() {
    S.gameok = 1; S.auto = 0; S.autoUsed = 0; S.showauto = 0; await levelPage(); if (!S.gameok) return;
    S.score = 7000; S.miss = 0; S.shotno = 0; for (var i = 0; i < 10; i++) for (var j = 0; j < 10; j++) S.seen[i][j] = 0;
    buildMaze(S.refl); resetBoardView();
    for (var shot = 1; shot <= NSHOT; shot++) {
      S.shotno = shot; statusReset(); var p; do { p = 10 + rnd(40); } while (S.used[p]);
      S.used[p] = 1; trace(p); S.used[S.exitp] = 1; var c = CT[(shot - 1) % 14], dash = shot > 14 ? 1 : 0;
      var gs = await readGuess(p);
      if (gs < 0) { msg(2, "遊戲中止", 12); S.soldv = 0; render(); await sleep(1000); S.gameok = 0; return; }
      msg(2, "", 15); await doShot(p, gs, c, dash);
      for (var n = 0; n < S.nh; n++) S.seen[S.hci[n]][S.hcj[n]] = 1;
      S.ucol[p] = c; S.ucol[S.exitp] = c; render();
      var bs = 0; msg(2, "", 15);
      if (S.hit) {
        if (S.bb > 10) { var bu = S.bb * 30; bs += bu; msg(2, "加分！！　" + bu + " 分　！！加分", 14); for (n = 1; n <= 8; n++) await snd(1000 + n * 100, 1); }
        else if (S.bb > 6) { bs += 200; msg(2, "200 分！！！加分！！！200 分", 14); for (n = 1; n <= 4; n++) await snd(1000 + n * 150, 1); }
        bs += Math.floor(2000 * S.bb / S.tk); msg(1, "答對了……答對了……答對了", 10);
        await snd(523, 2); await snd(659, 2); await snd(784, 2); await snd(1047, 4);
      } else { S.miss++; msg(1, "可惜…答錯了", 12); msg(2, "光束其實從 " + S.exitp + " 號出來", 12); await snd(220, 4); await snd(165, 6); }
      S.score += bs; msg(3, "本發得分 " + bs + "　總分 " + S.score, 11); await zz(1800);
      if (!S.hit && S.miss === 3) {
        msg(2, "要重看玩法說明嗎？（Y／N）", 15); clearBtns(); addBtn(556, 296, 80, 32, "是 Y", 89); addBtn(556, 344, 80, 32, "否 N", 78);
        var r = await waitChoice(); clearBtns(); if (r === 1) { await tutorial(); S.gameok = 0; return; }
      }
    }
    statusReset();
    if (S.miss === 0) { var bn = 20 * S.refl; S.score += bn; msg(1, "全部答對！！加分 " + bn + " 分！！全部答對", 14); for (n = 1; n <= 12; n++) await snd(800 + n * 80, 1); }
    if (S.score > S.hi) S.hi = S.score; if (!S.autoUsed) NMNS.finish(24, S.score);
    S.endview = 1; S.auto = 0; msg(2, "本局結束…你的得分是 " + S.score + "（黃色＝沒被打到的反射鏡）", 15); msg(3, "最高分是 " + S.hi + (S.autoUsed ? "　（用了自動解答，不登錄高分榜）" : ""), 10);
    clearBtns(); addBtn(556, 296, 80, 32, "下一局", 13); var r2 = await waitChoice(); clearBtns(); if (r2 < 0) S.gameok = 0;
    if (S.score > 3000) { S.refl = 30; S.lvl = "進階"; } if (S.score > 4000) { S.refl = 40; S.lvl = "中級"; }
    if (S.score > 5000) { S.refl = 50; S.lvl = "高級"; } if (S.score > 6000) { S.refl = 60; S.lvl = "大師級"; } if (S.score > 7000) { S.refl = 70; S.lvl = "大師級"; }
  }
  async function page(l1, l2) { msg(1, l1, 15); msg(2, l2, 15); msg(3, "", 15); clearBtns(); addBtn(556, 296, 80, 32, "下一頁 >", 13); var r = await waitChoice(); clearBtns(); if (r < 0) S.quittut = 1; }
  async function demo(p, c) { trace(p); S.soldx = S.geo[p].sx; S.soldy = S.geo[p].sy; S.soldv = 1; await doShot(p, S.exitp, c, 0); }
  async function tutorial() {
    S.quittut = 0; S.auto = 0; for (var i = 0; i < 10; i++) for (var j = 0; j < 10; j++) S.maz[i][j] = 0;
    [[3, 5, 1], [5, 4, 2], [9, 5, 1], [5, 8, 2], [6, 5, 1], [1, 2, 1], [2, 8, 1], [5, 1, 2], [8, 2, 2], [8, 9, 2]].forEach(function (m) { S.maz[m[0]][m[1]] = m[2]; });
    resetBoardView(); S.shotno = 0; statusReset();
    await page("盒子四周的每個號碼，都是光束可以進入或離開的出入口。", "士兵從入口號碼開火，你要點出光束出來的號碼。"); if (S.quittut) return;
    await page("斜線是反射鏡，會把光束轉向右、左、上或下。", "反射鏡一直看得見，要靠你推算光束怎麼走。"); if (S.quittut) return;
    statusReset(); msg(1, "請看光束從 22 號進入…", 15); await demo(22, CT[0]);
    await page("光束打到反射鏡，轉向正上方，從 11 號出來。", ""); if (S.quittut) return;
    statusReset(); msg(1, "再看光束從 20 號進入…", 15); await demo(20, CT[1]);
    await page("光束沒有碰到任何反射鏡，直接從 40 號出來。", "現在換你試試，點出每道光束的出口號碼。"); if (S.quittut) return;
    var ps5 = [29, 15, 39, 33, 31];
    for (var q = 1; q <= 5; q++) {
      var p = ps5[q - 1]; statusReset(); trace(p); var gs = await readGuess(p);
      if (gs < 0) { S.soldv = 0; render(); return; }
      await doShot(p, gs, CT[1 + q], 0);
      if (S.hit) msg(1, "答對了！" + p + " 號光束從 " + S.exitp + " 號出來。", 10); else msg(1, "差一點！" + p + " 號光束其實從 " + S.exitp + " 號出來。", 12);
      await zz(2000);
    }
    S.auto = 0;
    await page("得分取決於碰到的反射鏡數量與回答速度。", "猜中路徑特別複雜的光束，可以拿到額外加分。"); if (S.quittut) return;
    await page("每局有 20 道光束，每個號碼只會用一次。", "得分越高，下一局的反射鏡越多。");
  }
  async function title() {
    S.scrn = 0; S.showmenu = 0; S.beams = []; S.live = []; S.fx = []; S.soldv = 0; S.alv = 0; statusReset(); clearBtns();
    S.auto = 0; S.showauto = 0; addBtn(220, 216, 200, 32, "1) 開始遊戲", 49, 80); addBtn(220, 264, 200, 32, "2) 玩法說明", 50, 73); addBtn(220, 312, 200, 32, "3) 離開", 51, 81);
    var r; do { r = await waitChoice(); } while (r <= 0); clearBtns(); return r;
  }
  async function main() {
    while (true) {
      var ch = await title();
      if (ch === 1) { do { await playGame(); } while (S.gameok === 1); }
      else if (ch === 2) await tutorial();
      else { S.scrn = 9; S.btns = []; render(); ctext(12, "謝謝你玩雷射迷宮", 14); await sleep(1500); }
    }
  }
  reset();
  root.append(h("div", { class: "row c" }, cv.c), help);
  main();
});

// 30 電腦繪圖：電腦輔助塗色與畫圖
NMNS.register(30, function (root) {
  var W = 640, Hh = 420, cv = makeCanvas(W, Hh), c = cv.c, g = cv.g, m = msgBar();
  var PAL = ["#000000", "#ffffff", "#e63946", "#f4a261", "#ffd166", "#06d6a0", "#118ab2", "#073b4c", "#8338ec", "#ff70a6", "#8d5524", "#9ca3af"];
  var tool = "pen", col = "#e63946", size = 4, hist = [], down = false, last = null, start = null, snap = null, tmpl = 0;
  var toolBox = h("div", { class: "row" }), palBox = h("div", { class: "row" });
  var TOOLS = [["pen", "✏️ 畫筆"], ["line", "／ 直線"], ["rect", "▭ 方框"], ["circle", "◯ 圓"], ["fill", "🪣 填色"], ["eraser", "🧽 橡皮擦"]];

  function template(n) {
    g.fillStyle = "#fff"; g.fillRect(0, 0, W, Hh); g.strokeStyle = "#111"; g.lineWidth = 3; g.lineJoin = "round";
    function L() { g.beginPath(); for (var i = 0; i < arguments.length; i += 2) i ? g.lineTo(arguments[i], arguments[i + 1]) : g.moveTo(arguments[i], arguments[i + 1]); g.stroke(); }
    function B(x, y, w, hh) { g.strokeRect(x, y, w, hh); } function O(x, y, r) { g.beginPath(); g.arc(x, y, r, 0, 7); g.stroke(); }
    if (n === 1) { B(200, 200, 240, 160); L(180, 200, 320, 90, 460, 200, 180, 200); B(290, 270, 60, 90); B(225, 235, 45, 45); B(370, 235, 45, 45); O(560, 70, 32); L(0, 360, W, 360); }
    if (n === 2) { g.beginPath(); g.ellipse(300, 210, 150, 85, 0, 0, 7); g.stroke(); L(448, 210, 540, 140, 540, 280, 448, 210); O(210, 190, 11); L(260, 130, 310, 90, 345, 135); O(110, 110, 14); O(80, 70, 9); O(125, 50, 6); }
    if (n === 3) { B(280, 250, 60, 140); O(310, 190, 75); O(245, 235, 52); O(375, 235, 52); L(0, 390, W, 390); O(540, 80, 28); O(90, 80, 20); O(120, 74, 26); O(155, 82, 18); }
  }
  function save() { hist.push(g.getImageData(0, 0, W, Hh)); if (hist.length > 30) hist.shift(); }
  function undo() { if (hist.length) { g.putImageData(hist.pop(), 0, 0); } }
  function pos(e) { return canvasPos(c, e); }
  function hex(s) { return [parseInt(s.slice(1, 3), 16), parseInt(s.slice(3, 5), 16), parseInt(s.slice(5, 7), 16)]; }
  function flood(x, y, fc) {
    x = Math.round(x); y = Math.round(y); var img = g.getImageData(0, 0, W, Hh), d = img.data, f = hex(fc);
    function idx(a, b) { return (b * W + a) * 4; } var s = idx(x, y), t = [d[s], d[s + 1], d[s + 2]];
    if (Math.abs(t[0] - f[0]) + Math.abs(t[1] - f[1]) + Math.abs(t[2] - f[2]) < 6) return;
    function near(i) { return Math.abs(d[i] - t[0]) + Math.abs(d[i + 1] - t[1]) + Math.abs(d[i + 2] - t[2]) < 120; }
    var st = [[x, y]];
    while (st.length) {
      var p = st.pop(), px = p[0], py = p[1]; if (py < 0 || py >= Hh) continue; var i = idx(px, py); if (!near(i)) continue;
      var l = px, r = px; while (l > 0 && near(idx(l - 1, py))) l--; while (r < W - 1 && near(idx(r + 1, py))) r++;
      for (var k = l; k <= r; k++) { var j = idx(k, py); d[j] = f[0]; d[j + 1] = f[1]; d[j + 2] = f[2]; d[j + 3] = 255; }
      for (var dy = -1; dy <= 1; dy += 2) { var yy = py + dy, inn = false; if (yy < 0 || yy >= Hh) continue; for (k = l; k <= r; k++) { var ok = near(idx(k, yy)); if (ok && !inn) st.push([k, yy]); inn = ok; } }
    }
    g.putImageData(img, 0, 0);
  }
  function setStyle() { g.strokeStyle = tool === "eraser" ? "#ffffff" : col; g.fillStyle = col; g.lineWidth = tool === "eraser" ? size * 3 : size; g.lineCap = "round"; g.lineJoin = "round"; }
  c.addEventListener("pointerdown", function (e) {
    var p = pos(e); c.setPointerCapture(e.pointerId);
    if (tool === "fill") { save(); flood(p.x, p.y, col); return; }
    save(); down = true; last = p; start = p; snap = g.getImageData(0, 0, W, Hh); setStyle();
    if (tool === "pen" || tool === "eraser") { g.beginPath(); g.moveTo(p.x, p.y); g.lineTo(p.x + .1, p.y + .1); g.stroke(); }
  });
  c.addEventListener("pointermove", function (e) {
    if (!down) return; var p = pos(e); setStyle();
    if (tool === "pen" || tool === "eraser") { g.beginPath(); g.moveTo(last.x, last.y); g.lineTo(p.x, p.y); g.stroke(); last = p; return; }
    g.putImageData(snap, 0, 0); g.beginPath();
    if (tool === "line") { g.moveTo(start.x, start.y); g.lineTo(p.x, p.y); g.stroke(); }
    else if (tool === "rect") g.strokeRect(start.x, start.y, p.x - start.x, p.y - start.y);
    else if (tool === "circle") { g.arc(start.x, start.y, Math.hypot(p.x - start.x, p.y - start.y), 0, 7); g.stroke(); }
  });
  function up() { down = false; } c.addEventListener("pointerup", up); c.addEventListener("pointercancel", up);
  function renderTools() {
    toolBox.innerHTML = ""; TOOLS.forEach(function (t) { toolBox.append(btn(t[1], function () { tool = t[0]; renderTools(); m.say(t[0] === "fill" ? "填色：點封閉的區域，整塊上色（區域要封閉才不會漏色）。" : "工具：" + t[1], "info"); }, "choice sm" + (tool === t[0] ? " sel" : ""))); });
    toolBox.append(btn("↶ 復原", undo, "alt sm"), btn("清空", function () { save(); template(tmpl); }, "alt sm"), btn("換塗色圖", function () { tmpl = (tmpl + 1) % 4; save(); template(tmpl); m.say(["空白畫布", "塗色圖：房子", "塗色圖：魚", "塗色圖：大樹"][tmpl], "info"); }, "alt sm"),
      btn("💾 存成圖片", function () { var a = document.createElement("a"); a.download = "nmns30-drawing.png"; a.href = c.toDataURL("image/png"); a.click(); }, "alt sm"));
  }
  function renderPal() {
    palBox.innerHTML = "顏色："; PAL.forEach(function (p) { palBox.append(h("button", { class: "btn", type: "button", "aria-label": "顏色 " + p, style: "width:34px;min-height:34px;padding:0;border-radius:50%;background:" + p + ";border:3px solid " + (p === col ? "#f59e0b" : "#999"), onclick: function () { col = p; if (tool === "eraser") tool = "pen"; renderPal(); renderTools(); } })); });
    var sz = h("input", { type: "range", min: 1, max: 24, value: size, "aria-label": "筆刷粗細" }); sz.addEventListener("input", function () { size = +sz.value; }); palBox.append(" 粗細", sz);
  }
  window.addEventListener("keydown", function (e) { if ((e.ctrlKey || e.metaKey) && e.key === "z") { e.preventDefault(); undo(); } });
  c.style.touchAction = "none"; c.style.cursor = "crosshair";
  root.append(m.el, toolBox, palBox, c, h("p", { class: "link" }, "電腦畫面由許多小點（像素）組成，每一點有位置 (x, y) 和顏色。直線、方框、圓是用幾個數字定義；填色則是把相連、同色的區域全部換成新顏色。"));
  template(0); renderTools(); renderPal(); m.say("選工具和顏色，在畫布上畫畫。按「換塗色圖」可以幫房子、魚、大樹上色。", "info");
});

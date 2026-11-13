// 05 有趣的擺線：利用函數觀念設計擺線圖形
NMNS.register(5, function (root) {
  var W = 640, Hh = 420, cv = makeCanvas(W, Hh), g = cv.g;
  var typeSel = h("select", {}, h("option", { value: 0 }, "擺線（圓在直線上滾動）"), h("option", { value: 1 }, "內擺線（圓在大圓內滾動）"), h("option", { value: 2 }, "外擺線（圓在大圓外滾動）"));
  var rS = h("input", { type: "range", min: 10, max: 110, value: 40 }), dS = h("input", { type: "range", min: 10, max: 160, value: 100 });
  var rL = h("span", { class: "pill" }), dL = h("span", { class: "pill" }), formula = h("div", { class: "msg info mono" });
  var R = 120, raf = 0;

  function gcd(a, b) { return b ? gcd(b, a % b) : a; }
  function curve() {
    var t = +typeSel.value, r = +rS.value, d = +dS.value / 100 * r, pts = [], T;
    if (t === 0) { T = 6 * Math.PI; for (var s = 0; s <= 600; s++) { var u = T * s / 600; pts.push([r * u - d * Math.sin(u), r - d * Math.cos(u)]); } }
    else {
      T = 2 * Math.PI * r / gcd(R, r); var k = t === 1 ? R - r : R + r, sg = t === 1 ? 1 : -1;
      var N = Math.max(400, Math.min(2400, Math.round(T * 40)));
      for (var s2 = 0; s2 <= N; s2++) { var v = T * s2 / N; pts.push([k * Math.cos(v) + sg * d * Math.cos(k / r * v), k * Math.sin(v) - sg * d * Math.sin(k / r * v)]); }
    }
    return pts;
  }
  function fit(pts) {
    var x0 = 1e9, x1 = -1e9, y0 = 1e9, y1 = -1e9;
    pts.forEach(function (p) { x0 = Math.min(x0, p[0]); x1 = Math.max(x1, p[0]); y0 = Math.min(y0, p[1]); y1 = Math.max(y1, p[1]); });
    var rr = +rS.value; x0 -= rr; x1 += rr; y0 -= rr * (typeSel.value === "0" ? 0.1 : 1); y1 += rr * (typeSel.value === "0" ? 2.1 : 1);
    var sc = Math.min((W - 40) / (x1 - x0), (Hh - 40) / (y1 - y0));
    return { sc: sc, ox: (W - sc * (x1 - x0)) / 2 - sc * x0, oy: (Hh - sc * (y1 - y0)) / 2 - sc * y0, flip: typeSel.value === "0" };
  }
  function start() {
    cancelAnimationFrame(raf);
    var t = +typeSel.value, r = +rS.value, dd = +dS.value;
    rL.textContent = "滾動圓半徑 r = " + r; dL.textContent = "描點位置 = " + dd + "% r";
    formula.textContent = t === 0 ? "x = r·t − d·sin t,  y = r − d·cos t   （r=" + r + ", d=" + (dd / 100 * r).toFixed(0) + "）"
      : t === 1 ? "x = (R−r)cos t + d·cos((R−r)t/r),  y = (R−r)sin t − d·sin((R−r)t/r)   （R=" + R + "）"
      : "x = (R+r)cos t − d·cos((R+r)t/r),  y = (R+r)sin t − d·sin((R+r)t/r)   （R=" + R + "）";
    var pts = curve(), f = fit(pts), i = 0;
    function P(p) { return [f.ox + f.sc * p[0], f.flip ? Hh - 20 - f.sc * p[1] : f.oy + f.sc * p[1]]; }
    function frame() {
      g.fillStyle = "#fff"; g.fillRect(0, 0, W, Hh);
      g.strokeStyle = "#999"; g.lineWidth = 1;
      if (t === 0) { g.beginPath(); g.moveTo(0, Hh - 20); g.lineTo(W, Hh - 20); g.stroke(); }
      else { g.beginPath(); g.arc(f.ox, f.oy, R * f.sc, 0, 7); g.stroke(); }
      g.strokeStyle = "#c0392b"; g.lineWidth = 2; g.beginPath();
      for (var k = 0; k <= i; k++) { var q = P(pts[k]); k ? g.lineTo(q[0], q[1]) : g.moveTo(q[0], q[1]); }
      g.stroke();
      // 滾動圓與描點
      var u = pts.length ? i / (pts.length - 1) : 0, cx, cy, rr = +rS.value, p = P(pts[i]);
      if (t === 0) { var tt = 6 * Math.PI * u; cx = f.ox + f.sc * rr * tt; cy = Hh - 20 - f.sc * rr; }
      else { var T2 = 2 * Math.PI * rr / gcd(R, rr), v = T2 * u, kk = t === 1 ? R - rr : R + rr; cx = f.ox + f.sc * kk * Math.cos(v); cy = f.oy + f.sc * kk * Math.sin(v); }
      g.strokeStyle = "#2b6cb0"; g.lineWidth = 1.5; g.beginPath(); g.arc(cx, cy, rr * f.sc, 0, 7); g.stroke();
      g.beginPath(); g.moveTo(cx, cy); g.lineTo(p[0], p[1]); g.stroke();
      g.fillStyle = "#c0392b"; g.beginPath(); g.arc(p[0], p[1], 4, 0, 7); g.fill();
      if (i < pts.length - 1) { i = Math.min(pts.length - 1, i + Math.max(1, Math.round(pts.length / 240))); raf = requestAnimationFrame(frame); }
    }
    frame();
  }
  [typeSel, rS, dS].forEach(function (e) { e.addEventListener("input", start); });
  root.append(
    h("div", { class: "row" }, "種類：", typeSel),
    h("div", { class: "row" }, "滾動圓大小", rS, rL), h("div", { class: "row" }, "描點遠近", dS, dL),
    formula, cv.c, h("div", { class: "row" }, btn("重新播放", start)),
    h("p", { class: "link" }, "描點 100% 是圓周上的點（標準擺線）；小於 100% 在圓內（短幅），大於 100% 在圓外（長幅）。調整參數就是改變函數的係數。"));
  start();
});

// NMNS30 共用小工具：不依賴任何套件，純原生 JavaScript。
(function () {
  var NMNS = (window.NMNS = { games: {} });
  NMNS.register = function (n, fn) { NMNS.games[n] = fn; };

  // 建立 DOM：h('div', {class:'x', onclick:fn}, 子節點...)
  window.h = function (tag, props) {
    var e = document.createElement(tag);
    props = props || {};
    for (var k in props) {
      var v = props[k];
      if (k === "class") e.className = v;
      else if (k === "style") e.style.cssText = v;
      else if (k === "html") e.innerHTML = v;
      else if (k.slice(0, 2) === "on") e.addEventListener(k.slice(2), v);
      else if (v !== false && v != null) e.setAttribute(k, v);
    }
    for (var i = 2; i < arguments.length; i++) add(e, arguments[i]);
    return e;
  };
  function add(e, c) {
    if (c == null || c === false) return;
    if (Array.isArray(c)) c.forEach(function (x) { add(e, x); });
    else e.append(c instanceof Node ? c : document.createTextNode(String(c)));
  }
  window.rnd = function (n) { return Math.floor(Math.random() * n); };
  window.pick = function (a) { return a[rnd(a.length)]; };
  window.shuffle = function (a) {
    a = a.slice();
    for (var i = a.length - 1; i > 0; i--) { var j = rnd(i + 1), t = a[i]; a[i] = a[j]; a[j] = t; }
    return a;
  };
  window.clamp = function (v, lo, hi) { return Math.max(lo, Math.min(hi, v)); };
  window.sleep = function (ms) { return new Promise(function (r) { setTimeout(r, ms); }); };

  // 按鈕
  window.btn = function (text, onclick, cls) {
    return h("button", { class: "btn " + (cls || ""), type: "button", onclick: onclick }, text);
  };
  // 訊息列：回傳 {el, say(text, kind)}，kind = ok | bad | info
  window.msgBar = function () {
    var el = h("div", { class: "msg info", role: "status", "aria-live": "polite" });
    return {
      el: el,
      say: function (t, kind) { el.textContent = t; el.className = "msg " + (kind || "info"); }
    };
  };
  // 畫布：回傳 {c, g}；內部解析度固定，CSS 自動縮放
  window.makeCanvas = function (w, hh) {
    var c = h("canvas", { width: w, height: hh, class: "cv" });
    return { c: c, g: c.getContext("2d") };
  };
  // 把指標事件換成畫布座標
  window.canvasPos = function (c, ev) {
    var r = c.getBoundingClientRect();
    return { x: ((ev.clientX - r.left) * c.width) / r.width, y: ((ev.clientY - r.top) * c.height) / r.height };
  };
  // 方向鍵不要捲動頁面
  window.captureArrows = function () {
    window.addEventListener("keydown", function (e) {
      if (["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight", " "].indexOf(e.key) >= 0 &&
          !/INPUT|SELECT|TEXTAREA|BUTTON/.test(document.activeElement.tagName)) e.preventDefault();
    });
  };
  // 螢幕方向鍵（手機用）：onDir('U'|'D'|'L'|'R')
  window.dpad = function (onDir) {
    function b(t, d, g) { return h("button", { class: "btn dp", type: "button", style: "grid-area:" + g, onclick: function () { onDir(d); }, "aria-label": d }, t); }
    return h("div", { class: "dpad" }, b("▲", "U", "u"), b("◀", "L", "l"), b("▶", "R", "r"), b("▼", "D", "d"));
  };
  // 四則運算題產生器：回傳 {q, a}
  window.arith = function (level) {
    var op = pick(level > 1 ? ["+", "-", "×", "÷"] : ["+", "-", "×"]), a, b;
    if (op === "+") { a = 2 + rnd(level * 20 + 10); b = 2 + rnd(level * 20 + 10); return { q: a + " + " + b, a: a + b }; }
    if (op === "-") { a = 10 + rnd(level * 20 + 10); b = 1 + rnd(a - 1); return { q: a + " − " + b, a: a - b }; }
    if (op === "×") { a = 2 + rnd(level * 3 + 6); b = 2 + rnd(level * 3 + 6); return { q: a + " × " + b, a: a * b }; }
    b = 2 + rnd(8); a = b * (2 + rnd(level * 3 + 6)); return { q: a + " ÷ " + b, a: a / b };
  };
  // 簡單選擇題：回傳 DOM，answer(i) 於點選時呼叫
  window.choices = function (opts, onPick) {
    var box = h("div", { class: "choices" });
    opts.forEach(function (t, i) {
      box.append(btn(t, function () { onPick(i, box); }, "choice"));
    });
    return box;
  };
  // 分頁按鈕：tabs(['A','B'], function(i){...}) 回傳 {el, sel(i)}
  window.tabs = function (names, onSel) {
    var bar = h("div", { class: "row" }), bs = [];
    function sel(i) {
      bs.forEach(function (b, j) { b.classList.toggle("alt", j !== i); });
      onSel(i);
    }
    names.forEach(function (t, i) { bs.push(btn(t, function () { sel(i); }, "alt sm")); });
    bs.forEach(function (b) { bar.append(b); });
    return { el: bar, sel: sel };
  };
})();

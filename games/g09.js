// 09 高爾夫球：練習四則運算技巧
NMNS.register(9, function (root) {
  var W = 640, Hc = 200, cv = makeCanvas(W, Hc), g = cv.g, m = msgBar(), qBox = h("div");
  var HOLES = [[90, 3], [140, 3], [180, 4], [120, 3], [230, 4], [160, 4], [280, 5], [100, 3], [200, 4]];
  var hole, strokes, pos, total, totalPar, scores, busy, level = 1;
  var power = h("input", { type: "range", min: 10, max: 300, value: 100, "aria-label": "力道" }), pl = h("span", { class: "pill" });
  var info = h("div", { class: "row" });

  function sx(v) { return 30 + v / 320 * (W - 60); }
  function draw(bx, by) {
    g.fillStyle = "#cfe8ff"; g.fillRect(0, 0, W, Hc); g.fillStyle = "#4ca85a"; g.fillRect(0, 150, W, 50);
    g.fillStyle = "#79c58a"; g.fillRect(sx(HOLES[hole][0]) - 22, 150, 44, 50);
    g.fillStyle = "#222"; g.fillRect(sx(HOLES[hole][0]) - 2, 90, 3, 60); g.fillStyle = "#e53935"; g.fillRect(sx(HOLES[hole][0]) + 1, 90, 18, 12);
    g.fillStyle = "#444"; g.beginPath(); g.ellipse(sx(HOLES[hole][0]), 151, 6, 2.5, 0, 0, 7); g.fill();
    g.fillStyle = "#fff"; g.beginPath(); g.arc(bx == null ? sx(pos) : bx, by == null ? 146 : by, 5, 0, 7); g.fill(); g.strokeStyle = "#666"; g.stroke();
    g.fillStyle = "#14532d"; g.font = "12px sans-serif"; g.fillText("發球", sx(0) - 12, 172);
  }
  function upd() {
    var h0 = HOLES[hole];
    info.textContent = "第 " + (hole + 1) + " 洞　標準桿 " + h0[1] + "　距離 " + h0[0] + " 公尺　已揮 " + strokes + " 桿　球離洞 " + Math.abs(h0[0] - pos).toFixed(0) + " 公尺";
    pl.textContent = "力道 " + power.value + " 公尺";
  }
  function newHole() {
    pos = 0; strokes = 0; busy = false; qBox.innerHTML = ""; draw(); upd();
    m.say("調整力道（想打幾公尺），按「揮桿」，答對運算題準度才會好。", "info");
  }
  function swing() {
    if (busy) return; busy = true;
    var q = arith(level), p = +power.value, opts = [q.a, q.a + 1 + rnd(4), Math.max(0, q.a - 1 - rnd(4))].filter(function (v, i, a) { return a.indexOf(v) === i; });
    while (opts.length < 3) opts.push(q.a + 5 + rnd(10));
    qBox.innerHTML = "";
    qBox.append(h("p", { class: "big" }, "揮桿前先算：" + q.q + " = ?"), choices(shuffle(opts).map(String), function (k, box) {
      var ok = Number(box.children[k].textContent) === q.a;
      qBox.innerHTML = ""; fly(p, ok);
    }));
  }
  async function fly(p, ok) {
    var dir = pos <= HOLES[hole][0] ? 1 : -1, err = ok ? (Math.random() - 0.5) * 0.12 : (Math.random() < 0.5 ? -1 : 1) * (0.2 + Math.random() * 0.25);
    var target = clamp(pos + dir * p * (1 + err), 0, 320), from = pos, steps = 40;
    m.say(ok ? "答對！揮桿穩定。" : "答錯了…揮桿失準！", ok ? "ok" : "bad");
    for (var i = 1; i <= steps; i++) {
      var t = i / steps, x = sx(from + (target - from) * t), y = 146 - Math.sin(Math.PI * t) * Math.min(110, 30 + p * 0.3);
      draw(x, y); await sleep(15);
    }
    pos = target; strokes++; draw(); upd();
    var d = Math.abs(HOLES[hole][0] - pos);
    if (d <= 4 || strokes >= 8) finish(d <= 4);
    else { busy = false; m.say("球離洞還有 " + d.toFixed(0) + " 公尺" + (pos > HOLES[hole][0] ? "（打過頭了，往回打）" : "") + "。", "info"); }
  }
  function finish(inHole) {
    var par = HOLES[hole][1], diff = strokes - par;
    var nm = strokes === 1 ? "一桿進洞！" : diff <= -2 ? "老鷹球" : diff === -1 ? "博蒂（小鳥）" : diff === 0 ? "標準桿" : diff === 1 ? "柏忌" : "超過標準桿 " + diff + " 桿";
    total += strokes; totalPar += par; scores.push(strokes);
    m.say((inHole ? "進洞！" : "已達 8 桿上限。") + " " + strokes + " 桿，" + nm + "。累計 " + total + " 桿（標準桿 " + totalPar + "）。", inHole ? "ok" : "bad");
    qBox.innerHTML = "";
    if (hole >= HOLES.length - 1) { NMNS.finish(9, total); qBox.append(h("p", { class: "big" }, "全部 9 洞完成！總桿數 " + total + "，與標準桿相差 " + (total - totalPar > 0 ? "+" : "") + (total - totalPar) + "。")); return; }
    qBox.append(btn("下一洞", function () { hole++; if (hole >= 4) level = 2; newHole(); }));
  }
  power.addEventListener("input", upd);
  root.append(info, h("div", { class: "row" }, "力道", power, pl, btn("揮桿", swing)), m.el, cv.c, qBox,
    h("p", { class: "link" }, "前幾洞是加減乘，後面會加入除法。答錯會讓球偏離很多。"));
  hole = 0; total = 0; totalPar = 0; scores = [];
  newHole();
});

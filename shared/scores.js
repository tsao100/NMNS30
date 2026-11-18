// 高分榜與反饋：用 Supabase REST（PostgREST），不需要任何套件。
// 設定在 data/config.js 的 SUPABASE_URL、SUPABASE_ANON_KEY（anon key 本來就是公開用的）。
(function () {
  var C = window.NMNS_CONFIG || {}, ON = !!(C.SUPABASE_URL && C.SUPABASE_ANON_KEY);
  var META = { 2: { u: "分" }, 3: { u: "題" }, 4: { u: "步", low: 1 }, 6: { u: "分" }, 9: { u: "桿", low: 1 }, 24: { u: "分" }, 27: { u: "題" }, 28: { u: "塊" }, 29: { u: "分" } };
  var api = NMNS.api = { enabled: ON };
  function req(method, path, body) {
    var o = { method: method, headers: { apikey: C.SUPABASE_ANON_KEY, "Content-Type": "application/json" } };
    if (!/^sb_/.test(C.SUPABASE_ANON_KEY)) o.headers.Authorization = "Bearer " + C.SUPABASE_ANON_KEY; // 新式 sb_publishable 金鑰不是 JWT，只放 apikey
    if (method === "POST") { o.headers.Prefer = "return=minimal"; o.body = JSON.stringify(body); }
    return fetch(C.SUPABASE_URL.replace(/\/$/, "") + "/rest/v1/" + path, o).then(function (r) {
      if (!r.ok) throw new Error("HTTP " + r.status); return method === "GET" ? r.json() : null;
    });
  }
  api.submitScore = function (game, variant, name, score, higher) { return req("POST", "scores", { game: game, variant: variant || "", name: name, score: score, higher_better: higher }); };
  api.topScores = function (game, variant, higher) {
    return req("GET", "scores?select=name,score,created_at&game=eq." + game + "&variant=eq." + encodeURIComponent(variant || "") + "&order=score." + (higher ? "desc" : "asc") + ",created_at.asc&limit=10");
  };
  api.submitFeedback = function (o) { return req("POST", "feedback", o); };

  function table(rows, unit, me) {
    if (!rows.length) return h("p", { class: "link" }, "還沒有人上榜，你來當第一名！");
    var t = h("table", { class: "t" }, h("tr", {}, h("th", {}, "名次"), h("th", {}, "暱稱"), h("th", {}, unit), h("th", {}, "日期")));
    rows.forEach(function (r, i) { var tr = h("tr", me && r.name === me.name && r.score === me.score ? { style: "font-weight:700" } : {}, h("td", {}, i + 1), h("td", {}, r.name), h("td", {}, r.score), h("td", {}, String(r.created_at || "").slice(0, 10))); t.append(tr); });
    return t;
  }
  function box() { var b = document.getElementById("scoreBox"); if (b) { b.innerHTML = ""; b.hidden = false; } return b; }
  function loadBoard(b, game, variant, unit, higher, me) {
    var area = h("div", {}, h("p", { class: "link" }, "讀取高分榜…")); b.append(area);
    api.topScores(game, variant, higher).then(function (rows) { area.replaceChildren(table(rows, unit, me)); }, function () { area.replaceChildren(h("p", { class: "link" }, "高分榜暫時讀不到。")); });
  }
  // 遊戲結束時呼叫：NMNS.finish(遊戲編號, 成績, {variant:"3 片"})。未設定資料庫時什麼都不做。
  NMNS.finish = function (game, score, opt) {
    if (!ON) return; var b = box(); if (!b) return; opt = opt || {};
    var m = META[game] || { u: "分" }, higher = !m.low, variant = opt.variant || "", unit = m.u, sent = false;
    var nm = h("input", { type: "text", maxlength: 20, placeholder: "你的暱稱（最多 20 字）", "aria-label": "暱稱", style: "max-width:14em" });
    try { nm.value = localStorage.getItem("nmns30-name") || ""; } catch (e) { }
    var st = h("span", { class: "link", role: "status" }), go;
    go = btn("🏆 登錄成績", function () {
      var n = nm.value.trim(); if (!n) { st.textContent = "請先輸入暱稱。"; nm.focus(); return; } if (sent) return; sent = true; go.disabled = true; st.textContent = "送出中…";
      try { localStorage.setItem("nmns30-name", n); } catch (e) { }
      api.submitScore(game, variant, n, Math.round(score), higher).then(function () { st.textContent = "已登錄！"; b.replaceChildren(head, h("p", {}, "你的成績：" + score + " " + unit + (variant ? "（" + variant + "）" : "")), table0()); loadBoard(b, game, variant, unit, higher, { name: n, score: Math.round(score) }); },
        function () { sent = false; go.disabled = false; st.textContent = "登錄失敗，請稍後再試。"; });
    });
    var head = h("h3", {}, "🏆 高分榜"), table0 = function () { return h("span"); };
    b.append(head, h("p", {}, "你的成績：" + score + " " + unit + (variant ? "（" + variant + "）" : "") + (higher ? "" : "（越少越好）")), h("div", { class: "row" }, nm, go, st));
    loadBoard(b, game, variant, unit, higher);
  };
  // 遊戲頁的「高分榜」按鈕
  NMNS.showBoard = function (game) {
    if (!ON) return; var b = box(); var m = META[game]; if (!m) { b.append(h("p", { class: "link" }, "這個遊戲沒有計分，所以沒有高分榜。")); return; }
    b.append(h("h3", {}, "🏆 高分榜"), h("p", { class: "link" }, "（若遊戲分難度，榜單依完成當時的難度分開；完成一局後會顯示該局的榜。）")); loadBoard(b, game, "", m.u, !m.low);
  };
  NMNS.scoreable = function (game) { return !!META[game]; };
})();

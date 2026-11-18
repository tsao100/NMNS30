# NMNS30｜電腦益智遊戲 30 款

國立自然科學博物館電腦益智室（1991）30 個遊戲單元的**瀏覽器版**，純 HTML + JavaScript + Canvas，沒有任何依賴，直接放上 GitHub Pages 即可遊玩。
`qbasic/` 內另附 DOS QBasic 復古版（G01–G30.BAS、MENU.BAS）。

- 名單來源：陳惠美，〈國立自然科學博物館電腦益智室簡介〉，《科學教育月刊》第 138 期，1991 年 3 月，第 71 頁。
- 原文只記載遊戲名稱與教育內容；各遊戲的規則與畫面是依教育內容重新設計，不是原版程式的還原。

## 結構
```
index.html        遊戲選單（30 張卡片）
play.html         遊戲頁，用 ?g=編號 載入 games/gNN.js
data/games.js     30 款的名稱、分類、教育內容
shared/           engine.js（共用小工具）、style.css
games/g01.js…g30.js  各遊戲（每款獨立一個檔）
qbasic/           QBasic 版原始碼
tests/            Playwright 煙霧測試（node tests/smoke.js [遊戲編號…]）
```

## 發布到 GitHub Pages
Settings → Pages → Branch: main / root。網址是 https://tsao100.github.io/NMNS30/

## 新增或修改遊戲
每個遊戲是 `NMNS.register(編號, function (root) { … })`，把畫面建在 `root` 裡即可；共用工具見 `shared/engine.js`（`h()` 建 DOM、`btn()`、`tabs()`、`makeCanvas()`、`arith()` 等）。

## 高分榜與反饋資料庫（Supabase，選用）
1. 在 Supabase 後台 SQL Editor 貼上並執行 `supabase/schema.sql`（建立 `scores`、`feedback` 兩張表與 RLS 權限）。
2. 把 Project URL 與 **anon public key** 填入 `data/config.js` 的 `SUPABASE_URL`、`SUPABASE_ANON_KEY`。不要放 service_role key。
3. 沒填就完全不啟用：遊戲照常玩，反饋頁退回 GitHub／Email／複製。
注意：成績由瀏覽器送出，懂技術的人可以偽造，只適合當趣味榜；反饋留言只能新增、不能公開讀取。

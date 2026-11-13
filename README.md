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
Settings → Pages → Branch: main / root。網址是 `https://<帳號>.github.io/<倉庫名>/`。

## 新增或修改遊戲
每個遊戲是 `NMNS.register(編號, function (root) { … })`，把畫面建在 `root` 裡即可；共用工具見 `shared/engine.js`（`h()` 建 DOM、`btn()`、`tabs()`、`makeCanvas()`、`arith()` 等）。

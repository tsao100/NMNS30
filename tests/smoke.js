// 用法: node tests/smoke.js 1 2 3   （不給參數就測全部）
const { chromium } = require('playwright');
const path = require('path');
(async () => {
  const nums = process.argv.slice(2).map(Number); const list = nums.length ? nums : Array.from({length:30},(_, i)=>i+1);
  const b = await chromium.launch(); let bad = 0;
  for (const n of list) {
    for (const vp of [{width:1000,height:800},{width:375,height:700}]) {
      const p = await b.newPage({viewport: vp}); const errs = [];
      p.on('pageerror', e => errs.push('pageerror: ' + e.message));
      p.on('console', m => { if (m.type() === 'error') errs.push('console: ' + m.text()); });
      await p.goto('file://' + path.resolve(__dirname, '..', 'play.html') + '?g=' + n);
      await p.waitForTimeout(400);
      const txt = await p.locator('#stage').innerText();
      const w = await p.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
      if (/載入失敗|還沒準備好|找不到/.test(txt)) errs.push('stage: ' + txt.slice(0, 60));
      if (w > 2) errs.push('horizontal overflow ' + w + 'px @' + vp.width);
      // 隨機操作 40 次（點按鈕、點畫布、按鍵），確認沒有 JS 例外
      if (vp.width === 1000) {
        for (let i = 0; i < 40; i++) {
          try {
            const r = Math.random();
            if (r < 0.55) { const bs = await p.$$('#stage button:not([disabled])'); if (bs.length) await bs[Math.floor(Math.random() * bs.length)].click({ timeout: 300, force: true }); }
            else if (r < 0.75) { const cs = await p.$$('#stage canvas'); if (cs.length) { const c = cs[Math.floor(Math.random() * cs.length)], bb = await c.boundingBox(); if (bb) await p.mouse.click(bb.x + Math.random() * bb.width, bb.y + Math.random() * bb.height); } }
            else await p.keyboard.press(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight',' ','Enter','1','2','3','a'][Math.floor(Math.random()*10)]);
          } catch (e) {}
          if (i % 8 === 0) await p.waitForTimeout(60);
        }
      }
      const hook = path.resolve(__dirname, 'g' + String(n).padStart(2, '0') + '.test.js');
      try { const fs = require('fs'); if (fs.existsSync(hook) && vp.width === 1000) await require(hook)(p, errs); } catch (e) { errs.push('hook: ' + e.message); }
      if (errs.length) { bad++; console.log('G' + n, '@' + vp.width, errs.join(' | ')); }
      await p.close();
    }
  }
  await b.close(); console.log(bad ? bad + ' failing pages' : 'ALL OK (' + list.length + ' games)'); process.exit(bad ? 1 : 0);
})();

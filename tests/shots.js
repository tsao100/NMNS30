const { chromium } = require('playwright'); const path = require('path');
(async () => {
  const b = await chromium.launch(); const nums = process.argv.slice(2).map(Number);
  for (const n of nums) { const p = await b.newPage({ viewport: { width: 420, height: 900 }, deviceScaleFactor: 1 });
    await p.goto('file://' + path.resolve(__dirname, '..', 'play.html') + '?g=' + n); await p.waitForTimeout(900);
    await p.screenshot({ path: process.env.OUT + '/g' + n + '.png', fullPage: true }); await p.close(); }
  await b.close();
})();

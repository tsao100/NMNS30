const { chromium } = require('playwright'); const path = require('path');
(async () => { const b = await chromium.launch(), p = await b.newPage(), errs = [];
  p.on('pageerror', e => errs.push(e.message));
  await p.goto('file://' + path.resolve(__dirname, '..', 'index.html'));
  const n = await p.locator('.card').count(), l = await p.locator('.card a.btn').evaluateAll(a => a.map(x => x.getAttribute('href')));
  console.log('cards', n, 'links ok', l.length === 30 && l[29] === 'play.html?g=30', errs.join('|') || 'no errors'); await b.close(); })();

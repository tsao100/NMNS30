module.exports = async (p, errs) => {
  const tabs = await p.$$('#stage .row button');
  for (const t of tabs) { await t.click(); await p.waitForTimeout(50); const n = await p.locator('#stage span.mono').count(); if (n < 50) errs.push('G18 tab ' + (await t.innerText()) + ' shows only ' + n + ' cells'); }
};

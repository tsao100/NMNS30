module.exports = async (p, errs) => {
  await p.fill('input[type=text]', '0123'); await p.click('text=擊球');
  const rows = await p.locator('table.t tr').count(); if (rows !== 2) errs.push('G17 rows ' + rows);
  const t = await p.locator('.pill').first().innerText(); if (!/還有 \d+ 種可能/.test(t)) errs.push('G17 cand: ' + t);
};

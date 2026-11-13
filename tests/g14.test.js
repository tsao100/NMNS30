module.exports = async (p, errs) => {
  await p.click('text=排列實驗室');
  const info = () => p.locator('#stage .msg').nth(1).innerText();
  let t = await info();
  if (!/= 0/.test(t) || !/有解/.test(t)) errs.push('G14 solved state: ' + t);
  const cell = i => p.locator('#stage .cellgrid button').nth(i);
  await cell(13).click(); await cell(14).click();
  const t2 = await info(); if (!/無解/.test(t2)) errs.push('G14 swap not unsolvable: ' + t2);
};

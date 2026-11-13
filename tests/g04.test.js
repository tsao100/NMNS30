module.exports = async (p, errs) => {
  await p.click('text=遞迴自動示範'); await p.waitForTimeout(4500);
  const t = await p.locator('.msg').innerText(); if (!/完成|2\^3/.test(t)) errs.push('G04 demo not finished: ' + t);
};

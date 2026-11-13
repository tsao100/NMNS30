module.exports = async (p, errs) => {
  // 76 條勝利線；連下同一柱 4 次電腦會擋，改驗證計數文字
  const t = await p.locator('.link').last().innerText(); if (!/76/.test(t)) errs.push('G19 lines count text: ' + t);
};

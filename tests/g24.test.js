module.exports = async (p, errs) => {
  // 關卡必須可解：用頁面內部狀態不可取，改驗證 20 次新地圖都能載入且目標圓存在
  for (let i = 0; i < 20; i++) { await p.click('text=換一張新地圖'); }
  const m = await p.locator('.msg').innerText(); if (!/第 \d/.test(m)) errs.push('G24 msg: ' + m);
};

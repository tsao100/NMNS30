module.exports = async (p, errs) => {
  await p.reload(); await p.waitForTimeout(400);
  // 原版教學盤面：22 → 11，20 → 40；29/15/39/33/31 的出口須與手算一致
  const r = await p.evaluate(() => {
    const L = window.__laser, S = L.S();
    for (let i = 0; i < 10; i++) for (let j = 0; j < 10; j++) S.maz[i][j] = 0;
    [[3,5,1],[5,4,2],[9,5,1],[5,8,2],[6,5,1],[1,2,1],[2,8,1],[5,1,2],[8,2,2],[8,9,2]].forEach(m => S.maz[m[0]][m[1]] = m[2]);
    return [22, 20, 29, 15, 39, 33, 31].map(x => [x, L.trace(x)]);
  });
  const want = {22: 11, 20: 40};
  r.forEach(([a, b]) => { if (want[a] && want[a] !== b) errs.push('G24 trace ' + a + ' -> ' + b); });
  // 進入遊戲：點 1) PLAY → START → 等待猜測畫面不報錯
  const box = await p.locator('#stage canvas').boundingBox();
  const click = (x, y) => p.mouse.click(box.x + x * box.width / 640, box.y + y * box.height / 480);
  await click(320, 232); await p.waitForTimeout(150); await click(320, 312); await p.waitForTimeout(200);
  await p.keyboard.type('11'); await p.waitForFunction(() => window.__laser.S().beams.length >= 1, null, { timeout: 15000 }).catch(() => {});
  const s = await p.evaluate(() => window.__laser.S()); if (s.shotno < 1 || s.beams.length < 1) errs.push('G24 shot not completed: shotno=' + s.shotno + ' beams=' + s.beams.length);
  // 自動解答：重新載入 → 開始 → 按 A → 20 發全對，且不登錄高分榜
  await p.reload(); await p.waitForTimeout(400);
  await p.evaluate(() => { window.__fin = 0; NMNS.finish = () => { window.__fin++; }; });
  const bx = await p.locator('#stage canvas').boundingBox();
  const clk = (x, y) => p.mouse.click(bx.x + x * bx.width / 640, bx.y + y * bx.height / 480);
  await clk(320, 232); await p.waitForTimeout(150); await clk(320, 312); await p.waitForTimeout(300);
  await p.keyboard.press('a');
  await p.waitForFunction(() => window.__laser.S().endview === 1, null, { timeout: 90000 }).catch(() => {});
  const a = await p.evaluate(() => { const S = window.__laser.S(); return { end: S.endview, miss: S.miss, score: S.score, shot: S.shotno, fin: window.__fin, beams: S.beams.length }; });
  if (a.end !== 1 || a.miss !== 0 || a.shot !== 20 || a.beams !== 20 || a.score <= 7000 || a.fin !== 0) errs.push('G24 auto ' + JSON.stringify(a));
  await p.screenshot({ path: '/tmp/claude-0/-home-claude/3f117e0c-b975-555a-a27f-1ab99ea5a9ef/scratchpad/g24_end.png' });
};

// 用假的 Supabase 伺服器（攔截 fetch）驗證：登錄成績、讀榜、反饋寫入
const { chromium } = require('playwright'); const path = require('path');
(async () => { const b = await chromium.launch(), errs = [], db = { scores: [], feedback: [] };
  const ctx = await b.newContext(); await ctx.route('https://x.supabase.co/**', async r => {
    const q = r.request(), u = new URL(q.url()), t = u.pathname.split('/').pop();
    if (q.headers().apikey !== "sb_publishable_KEY" || q.headers().authorization) return r.fulfill({ status: 401, body: '{}' });
    if (q.method() === 'POST') { db[t].push(JSON.parse(q.postData())); return r.fulfill({ status: 201, body: '' }); }
    const g = +u.searchParams.get('game').slice(3), asc = /asc/.test(u.searchParams.get('order'));
    const rows = db.scores.filter(x => x.game === g).sort((a, c) => asc ? a.score - c.score : c.score - a.score).slice(0, 10).map(x => ({ name: x.name, score: x.score, created_at: '2026-11-17T00:00:00Z' }));
    r.fulfill({ status: 200, contentType: 'application/json', headers: { 'access-control-allow-origin': '*' }, body: JSON.stringify(rows) }); });
  const p = await ctx.newPage(); p.on('pageerror', e => errs.push(e.message));
  const inject = () => p.addInitScript(() => { window.__cfg = 1; });
  await p.route('**/data/config.js*', r => r.fulfill({ contentType: 'text/javascript', body: 'window.NMNS_CONFIG={SUPABASE_URL:"https://x.supabase.co",SUPABASE_ANON_KEY:"sb_publishable_KEY",FEEDBACK_REPO:"a/b",FEEDBACK_EMAIL:"e@x.y"};' }));
  const base = 'file://' + path.resolve(__dirname, '..') + '/';
  // G04：完成 1 片漢諾塔後登錄（步數越少越好）
  await p.goto(base + 'play.html?g=4'); await p.waitForTimeout(400);
  await p.evaluate(() => NMNS.finish(4, 7, { variant: '3 片' }));
  await p.fill('#scoreBox input', '小明'); await p.click('#scoreBox button'); await p.waitForTimeout(400);
  const s = db.scores[0]; if (!s || s.game !== 4 || s.score !== 7 || s.higher_better !== false || s.variant !== '3 片' || s.name !== '小明') errs.push('score payload ' + JSON.stringify(s));
  if (!/小明/.test(await p.innerText('#scoreBox'))) errs.push('board not shown');
  // 空暱稱不送出
  await p.evaluate(() => NMNS.finish(4, 9, { variant: '3 片' })); await p.evaluate(() => { try { localStorage.removeItem('nmns30-name'); } catch (e) { } });
  await p.fill('#scoreBox input', ''); await p.click('#scoreBox button'); if (db.scores.length !== 1) errs.push('empty name sent');
  // 高分榜按鈕：G24 要有；G30 沒有
  await p.goto(base + 'play.html?g=24'); await p.waitForTimeout(300); if (await p.isHidden('#lb')) errs.push('lb hidden g24');
  await p.goto(base + 'play.html?g=30'); await p.waitForTimeout(300); if (!(await p.isHidden('#lb'))) errs.push('lb shown g30');
  // 反饋
  await p.goto(base + 'feedback.html?g=7'); await p.fill('#body', '當年老鼠是 m'); await p.fill('#who', 'abc'); await p.click('#send'); await p.waitForTimeout(400);
  const f = db.feedback[0]; if (!f || f.game !== 7 || f.body !== '當年老鼠是 m' || f.contact !== 'abc') errs.push('feedback payload ' + JSON.stringify(f));
  if (await p.isHidden('#gh') || await p.isHidden('#mail')) errs.push('alt buttons');
  console.log(errs.length ? errs : 'SCORES OK'); await b.close(); process.exit(errs.length ? 1 : 0); })();

-- NMNS30：高分榜與到訪者反饋。在 Supabase 後台 SQL Editor 整段貼上執行一次即可。
-- 設計原則：網頁只用「公開的 anon key」，所以權限全靠這裡的 RLS 限制：
--   scores   ：任何人可新增、可讀取（排行榜是公開的）；不能改、不能刪
--   feedback ：任何人只能新增；不能讀（聯絡方式屬於個人資料，只有你在後台看得到）

create table if not exists public.scores (
  id          bigint generated always as identity primary key,
  game        smallint not null check (game between 1 and 30),
  variant     text     not null default '' check (char_length(variant) <= 20),
  name        text     not null check (char_length(btrim(name)) between 1 and 20),
  score       integer  not null check (score between -100000 and 1000000),
  higher_better boolean not null default true,
  created_at  timestamptz not null default now()
);
create index if not exists scores_rank_idx on public.scores (game, variant, score desc, created_at);

create table if not exists public.feedback (
  id         bigint generated always as identity primary key,
  game       smallint not null default 0 check (game between 0 and 30),
  kind       text not null default '' check (char_length(kind) <= 30),
  body       text not null check (char_length(btrim(body)) between 1 and 4000),
  happened   text not null default '' check (char_length(happened) <= 120),
  contact    text not null default '' check (char_length(contact) <= 120),
  created_at timestamptz not null default now()
);

alter table public.scores   enable row level security;
alter table public.feedback enable row level security;

drop policy if exists scores_insert   on public.scores;
drop policy if exists scores_select   on public.scores;
drop policy if exists feedback_insert on public.feedback;
create policy scores_insert   on public.scores   for insert to anon with check (true);
create policy scores_select   on public.scores   for select to anon using (true);
create policy feedback_insert on public.feedback for insert to anon with check (true);

revoke all on public.scores, public.feedback from anon;
grant insert, select on public.scores   to anon;
grant insert         on public.feedback to anon;

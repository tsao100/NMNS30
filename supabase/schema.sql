-- NMNS30：高分榜與到訪者反饋。在 Supabase 後台 SQL Editor 整段貼上執行一次即可。
-- 設計原則：網頁只用「公開的 anon key」，所以權限全靠這裡的 RLS 限制：
--   scores   ：任何人可新增、可讀取（排行榜是公開的）；不能改、不能刪
--   feedback ：任何人可新增；可公開瀏覽留言內容（不含聯絡方式 contact，也不含被你設為 hidden 的列）

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
  hidden     boolean not null default false,   -- 站長想隱藏不當留言時，在後台把這格改成 true
  created_at timestamptz not null default now()
);
alter table public.feedback add column if not exists hidden boolean not null default false;
create index if not exists feedback_time_idx on public.feedback (created_at desc);

alter table public.scores   enable row level security;
alter table public.feedback enable row level security;

drop policy if exists scores_insert   on public.scores;
drop policy if exists scores_select   on public.scores;
drop policy if exists feedback_insert on public.feedback;
drop policy if exists feedback_select on public.feedback;
create policy scores_insert   on public.scores   for insert to anon with check (true);
create policy scores_select   on public.scores   for select to anon using (true);
create policy feedback_insert on public.feedback for insert to anon with check (true);
-- 留言可公開瀏覽，但只限未隱藏的列，且「聯絡方式 contact」欄位不開放讀取（見下方欄位層級授權）
create policy feedback_select on public.feedback for select to anon using (hidden = false);

revoke all on public.scores, public.feedback from anon;
grant insert, select on public.scores   to anon;
grant insert on public.feedback to anon;
grant select (id, game, kind, body, happened, created_at) on public.feedback to anon;

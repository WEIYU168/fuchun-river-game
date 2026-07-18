create table if not exists public.game_scores (
  id bigint generated always as identity primary key,
  player_name text not null check (
    char_length(player_name) between 1 and 16
    and player_name = btrim(player_name)
    and player_name !~ '[[:cntrl:]<>]'
  ),
  score integer not null check (score between 0 and 1000000),
  quiz_correct smallint not null check (quiz_correct between 0 and 100),
  quiz_total smallint not null check (quiz_total between 0 and 100),
  seals smallint not null check (seals between 0 and 20),
  created_at timestamptz not null default now(),
  check (quiz_correct <= quiz_total)
);

create index if not exists game_scores_ranking_idx
  on public.game_scores (score desc, quiz_correct desc, created_at asc);

alter table public.game_scores enable row level security;

revoke all on table public.game_scores from anon, authenticated;
grant select, insert on table public.game_scores to anon, authenticated;
grant usage, select on sequence public.game_scores_id_seq to anon, authenticated;

drop policy if exists "Anyone can read leaderboard" on public.game_scores;
create policy "Anyone can read leaderboard"
  on public.game_scores for select
  to anon, authenticated
  using (true);

drop policy if exists "Anyone can submit a valid score" on public.game_scores;
create policy "Anyone can submit a valid score"
  on public.game_scores for insert
  to anon, authenticated
  with check (
    char_length(player_name) between 1 and 16
    and player_name = btrim(player_name)
    and player_name !~ '[[:cntrl:]<>]'
    and score between 0 and 1000000
    and quiz_correct between 0 and quiz_total
    and quiz_total between 0 and 100
    and seals between 0 and 20
  );

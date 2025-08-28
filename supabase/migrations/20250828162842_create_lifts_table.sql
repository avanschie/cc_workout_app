create type lift_type as enum ('squat','bench','deadlift');

create table if not exists public.lift_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  lift lift_type not null,
  reps int2 not null check (reps between 1 and 10),
  weight_kg numeric(6,2) not null check (weight_kg > 0),
  performed_at date not null,
  created_at timestamptz not null default now()
);

-- Best per (user, lift, reps)
create or replace view public.rep_maxes as
select distinct on (user_id, lift, reps)
  user_id, lift, reps, weight_kg, performed_at, id as lift_entry_id
from (
  select
    le.*,
    row_number() over (
      partition by user_id, lift, reps
      order by weight_kg desc, performed_at desc, created_at desc
    ) as rnk
  from public.lift_entries le
) t
where rnk = 1
order by user_id, lift, reps;

alter table public.lift_entries enable row level security;

create policy "owner can read"
  on public.lift_entries for select
  using (auth.uid() = user_id);

create policy "owner can insert"
  on public.lift_entries for insert
  with check (auth.uid() = user_id);

create policy "owner can update"
  on public.lift_entries for update
  using (auth.uid() = user_id);

create policy "owner can delete"
  on public.lift_entries for delete
  using (auth.uid() = user_id);
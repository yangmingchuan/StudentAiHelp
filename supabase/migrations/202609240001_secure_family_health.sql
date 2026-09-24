-- Little Hero: secure family, tasks, medication and cycle data.
-- Apply in Supabase SQL Editor only after the chosen Supabase Auth flow is live.
-- The mobile client must use the anon/publishable key only; never embed service_role.

create extension if not exists pgcrypto;

create type public.household_role as enum ('owner', 'caregiver', 'viewer');
create type public.reminder_status as enum ('scheduled', 'completed', 'skipped', 'canceled');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_by uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now()
);

create table public.household_members (
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.household_role not null default 'caregiver',
  created_at timestamptz not null default now(),
  primary key (household_id, user_id)
);

create or replace function public.add_household_owner()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  insert into public.household_members (household_id, user_id, role)
  values (new.id, new.created_by, 'owner');
  return new;
end;
$$;

create trigger households_add_owner
  after insert on public.households
  for each row execute procedure public.add_household_owner();

create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.is_household_member(target_household_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.household_members m
    where m.household_id = target_household_id and m.user_id = auth.uid()
  );
$$;

create or replace function public.is_household_editor(target_household_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.household_members m
    where m.household_id = target_household_id
      and m.user_id = auth.uid()
      and m.role in ('owner', 'caregiver')
  );
$$;

create or replace function public.is_household_owner(target_household_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.household_members m
    where m.household_id = target_household_id
      and m.user_id = auth.uid()
      and m.role = 'owner'
  );
$$;

grant execute on function public.is_household_member(uuid) to authenticated;
grant execute on function public.is_household_editor(uuid) to authenticated;
grant execute on function public.is_household_owner(uuid) to authenticated;

create table public.children (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  name text not null,
  birth_date date,
  avatar_key text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.habit_templates (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  name text not null,
  icon_key text not null default '',
  description text not null default '',
  created_at timestamptz not null default now()
);

create table public.habits (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  template_id uuid references public.habit_templates(id) on delete set null,
  name text not null,
  icon_key text not null default '',
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Matches the product rule: at most ten active tasks per child per day.
create or replace function public.enforce_active_habit_limit()
returns trigger language plpgsql set search_path = public as $$
begin
  if new.is_active and (
    select count(*) from public.habits
    where child_id = new.child_id and is_active and id is distinct from new.id
  ) >= 10 then
    raise exception 'A child can have at most 10 active habits';
  end if;
  return new;
end;
$$;

create trigger habits_active_limit
  before insert or update of is_active, child_id on public.habits
  for each row execute procedure public.enforce_active_habit_limit();

create table public.habit_records (
  id uuid primary key default gen_random_uuid(),
  habit_id uuid not null references public.habits(id) on delete cascade,
  record_date date not null,
  completed_at timestamptz,
  operation_id uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (habit_id, record_date),
  unique (operation_id)
);

create table public.care_recipients (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  name text not null,
  relation text not null default '家庭成员',
  age_note text not null default '',
  allergy_note text not null default '',
  condition_note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.medicines (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  name text not null,
  specification text not null default '',
  default_dosage text not null default '',
  storage_location text not null default '',
  expires_on date,
  stock_note text not null default '',
  usage_note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.medication_logs (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  recipient_id uuid references public.care_recipients(id) on delete set null,
  medicine_id uuid references public.medicines(id) on delete set null,
  recipient_name text not null,
  medicine_name text not null,
  taken_at timestamptz not null,
  dosage_text text not null default '',
  reason text not null default '',
  note text not null default '',
  voided_at timestamptz,
  void_reason text not null default '',
  corrected_by_log_id uuid references public.medication_logs(id) on delete restrict,
  operation_id uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now(),
  unique (operation_id)
);

create table public.medication_reminders (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  source_log_id uuid references public.medication_logs(id) on delete set null,
  recipient_name text not null,
  medicine_name text not null,
  remind_at timestamptz not null,
  dosage_text text not null default '',
  status public.reminder_status not null default 'scheduled',
  resolved_at timestamptz,
  operation_id uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (operation_id)
);

create table public.cycle_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  last_period_start_date date not null,
  period_length_days smallint not null check (period_length_days between 1 and 15),
  cycle_length_days smallint not null check (cycle_length_days between 15 and 90),
  birth_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.cycle_periods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  started_on date not null,
  ended_on date,
  source text not null default 'manual',
  created_at timestamptz not null default now(),
  unique (user_id, started_on)
);

create table public.cycle_daily_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  log_date date not null,
  flow_level text not null default 'none',
  symptoms jsonb not null default '[]'::jsonb,
  diary_text text not null default '',
  operation_id uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, log_date),
  unique (operation_id)
);

alter table public.profiles enable row level security;
alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.children enable row level security;
alter table public.habit_templates enable row level security;
alter table public.habits enable row level security;
alter table public.habit_records enable row level security;
alter table public.care_recipients enable row level security;
alter table public.medicines enable row level security;
alter table public.medication_logs enable row level security;
alter table public.medication_reminders enable row level security;
alter table public.cycle_profiles enable row level security;
alter table public.cycle_periods enable row level security;
alter table public.cycle_daily_logs enable row level security;

create policy "read own profile" on public.profiles for select using (id = auth.uid());
create policy "update own profile" on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());

create policy "members read households" on public.households for select using (public.is_household_member(id));
create policy "user creates household" on public.households for insert with check (created_by = auth.uid());
create policy "edit household" on public.households for update using (public.is_household_editor(id));

create policy "members read memberships" on public.household_members for select using (public.is_household_member(household_id));
create policy "owners manage memberships" on public.household_members for all using (public.is_household_owner(household_id)) with check (public.is_household_owner(household_id));

-- Shared household tables: viewers can read; owners/caregivers can write.
create policy "read children" on public.children for select using (public.is_household_member(household_id));
create policy "edit children" on public.children for all using (public.is_household_editor(household_id)) with check (public.is_household_editor(household_id));
create policy "read habit templates" on public.habit_templates for select using (public.is_household_member(household_id));
create policy "edit habit templates" on public.habit_templates for all using (public.is_household_editor(household_id)) with check (public.is_household_editor(household_id));
create policy "read habits" on public.habits for select using (public.is_household_member(household_id));
create policy "edit habits" on public.habits for all using (public.is_household_editor(household_id)) with check (public.is_household_editor(household_id));
create policy "read habit records" on public.habit_records for select using (exists (select 1 from public.habits h where h.id = habit_id and public.is_household_member(h.household_id)));
create policy "edit habit records" on public.habit_records for all using (exists (select 1 from public.habits h where h.id = habit_id and public.is_household_editor(h.household_id))) with check (exists (select 1 from public.habits h where h.id = habit_id and public.is_household_editor(h.household_id)));
create policy "read care recipients" on public.care_recipients for select using (public.is_household_member(household_id));
create policy "edit care recipients" on public.care_recipients for all using (public.is_household_editor(household_id)) with check (public.is_household_editor(household_id));
create policy "read medicines" on public.medicines for select using (public.is_household_member(household_id));
create policy "edit medicines" on public.medicines for all using (public.is_household_editor(household_id)) with check (public.is_household_editor(household_id));
create policy "read medication logs" on public.medication_logs for select using (public.is_household_member(household_id));
create policy "edit medication logs" on public.medication_logs for all using (public.is_household_editor(household_id)) with check (public.is_household_editor(household_id));
create policy "read medication reminders" on public.medication_reminders for select using (public.is_household_member(household_id));
create policy "edit medication reminders" on public.medication_reminders for all using (public.is_household_editor(household_id)) with check (public.is_household_editor(household_id));

-- Cycle data is strictly private to the signed-in owner, even inside a household.
create policy "private cycle profile" on public.cycle_profiles for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "private cycle periods" on public.cycle_periods for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "private cycle daily logs" on public.cycle_daily_logs for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Do not add DELETE policies to medication logs or reminders: history is retained.

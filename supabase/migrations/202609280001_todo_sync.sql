-- Todo mobile sync v1. Deliberately leaves all existing project objects intact.
begin;
create table public.todo_sync_state (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  revision bigint not null default 0
);
create table public.todo_sync_receipts (
  owner_id uuid not null references auth.users(id) on delete cascade,
  operation_id text not null,
  entity text not null,
  record_key text not null,
  revision bigint not null,
  primary key(owner_id, operation_id)
);
alter table public.todo_sync_state enable row level security;
alter table public.todo_sync_receipts enable row level security;
revoke all on public.todo_sync_state, public.todo_sync_receipts from anon, authenticated;

do $$
declare entity text;
begin
  foreach entity in array array[
    'children','habits','habit_records','child_badges','daily_awards','rest_days',
    'rewards','reward_redemptions','cycle_profiles','cycle_day_logs',
    'medication_members','medicines','medication_logs','medication_reminders'
  ] loop
    execute format('create table public.%I (
      owner_id uuid not null references auth.users(id) on delete cascade,
      record_key text not null check(length(record_key) between 1 and 200),
      payload jsonb not null check(jsonb_typeof(payload) = ''object''),
      revision bigint not null,
      deleted boolean not null default false,
      updated_at timestamptz not null default now(),
      primary key(owner_id, record_key)
    )', 'todo_' || entity);
    execute format('alter table public.%I enable row level security', 'todo_' || entity);
    execute format('revoke all on public.%I from anon, authenticated', 'todo_' || entity);
    execute format('grant select on public.%I to authenticated', 'todo_' || entity);
    execute format('create policy todo_owner_read on public.%I for select to authenticated using (owner_id = (select auth.uid()))', 'todo_' || entity);
    execute format('create index on public.%I(owner_id, revision)', 'todo_' || entity);
  end loop;
end $$;

-- Only this RPC can write records, enforcing owner identity, revisions and retries.
create function public.todo_sync(p_cursor bigint default 0, p_changes jsonb default '[]')
returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare
  uid uuid := auth.uid();
  entity text;
  allowed text[] := array['children','habits','habit_records','child_badges','daily_awards','rest_days','rewards','reward_redemptions','cycle_profiles','cycle_day_logs','medication_members','medicines','medication_logs','medication_reminders'];
  change jsonb;
  current_row jsonb;
  receipt public.todo_sync_receipts%rowtype;
  rev bigint;
  next_rev bigint;
  accepted jsonb := '[]';
  conflicts jsonb := '[]';
  rows jsonb;
  union_sql text := '';
  next_cursor bigint;
begin
  if uid is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  if jsonb_typeof(p_changes) <> 'array' or jsonb_array_length(p_changes) > 200 or octet_length(p_changes::text) > 2000000 then
    raise exception 'Invalid sync batch';
  end if;
  insert into todo_sync_state(owner_id) values(uid) on conflict do nothing;
  select revision into next_rev from todo_sync_state where owner_id = uid for update;
  if p_cursor < 0 or p_cursor > next_rev then raise exception 'Invalid cursor'; end if;
  for change in select value from jsonb_array_elements(p_changes) loop
    entity := change->>'entity';
    if entity is null or not entity = any(allowed)
      or coalesce(length(change->>'key'),0) not between 1 and 200
      or coalesce(length(change->>'operation_id'),0) not between 1 and 100
      or jsonb_typeof(change->'payload') is distinct from 'object'
      or coalesce((change->>'base_revision')::bigint,-1) < 0 then
      raise exception 'Invalid record';
    end if;
    select * into receipt from todo_sync_receipts
      where owner_id = uid and operation_id = change->>'operation_id';
    if found then
      if receipt.entity <> entity or receipt.record_key <> change->>'key' then raise exception 'Operation ID reused'; end if;
      accepted := accepted || jsonb_build_array(jsonb_build_object('entity',entity,'key',receipt.record_key,'operation_id',receipt.operation_id,'revision',receipt.revision));
      continue;
    end if;
    execute format('select to_jsonb(t) from public.%I t where owner_id=$1 and record_key=$2', 'todo_'||entity)
      into current_row using uid, change->>'key';
    rev := coalesce((current_row->>'revision')::bigint,0);
    -- Identical imports/edits are safe to acknowledge without another version.
    if current_row is not null and current_row->'payload' = change->'payload'
      and (current_row->>'deleted')::boolean = coalesce((change->>'deleted')::boolean,false) then
      null;
    elsif rev <> (change->>'base_revision')::bigint then
      conflicts := conflicts || jsonb_build_array(jsonb_build_object('entity',entity,'key',change->>'key','operation_id',change->>'operation_id','remote',current_row));
      continue;
    else
      next_rev := next_rev + 1;
      rev := next_rev;
      execute format('insert into public.%I(owner_id,record_key,payload,revision,deleted) values($1,$2,$3,$4,$5)
        on conflict(owner_id,record_key) do update set payload=excluded.payload, revision=excluded.revision,deleted=excluded.deleted,updated_at=now()', 'todo_'||entity)
        using uid,change->>'key',change->'payload',rev,coalesce((change->>'deleted')::boolean,false);
    end if;
    insert into todo_sync_receipts values(uid,change->>'operation_id',entity,change->>'key',rev);
    accepted := accepted || jsonb_build_array(jsonb_build_object('entity',entity,'key',change->>'key','operation_id',change->>'operation_id','revision',rev));
  end loop;
  update todo_sync_state set revision=next_rev where owner_id=uid;
  foreach entity in array allowed loop
    if union_sql <> '' then union_sql := union_sql || ' union all '; end if;
    union_sql := union_sql || format('select %L::text as entity, record_key as key, payload, revision, deleted from public.%I where owner_id=$1 and revision>$2',entity,'todo_'||entity);
  end loop;
  execute 'select coalesce(jsonb_agg(to_jsonb(r) order by revision),''[]''::jsonb) from ('||union_sql||' order by revision limit 500) r'
    into rows using uid,p_cursor;
  select coalesce(max((value->>'revision')::bigint),p_cursor) into next_cursor from jsonb_array_elements(rows);
  return jsonb_build_object('accepted',accepted,'conflicts',conflicts,'rows',rows,'cursor',next_cursor,'has_more',next_cursor<next_rev);
end $$;
revoke all on function public.todo_sync(bigint,jsonb) from public, anon;
grant execute on function public.todo_sync(bigint,jsonb) to authenticated;
commit;

begin;
create table public.todo_auth_attempts (
  key_hash text primary key,
  window_start timestamptz not null default now(),
  attempts integer not null default 0
);
alter table public.todo_auth_attempts enable row level security;
revoke all on public.todo_auth_attempts from anon, authenticated;
create function public.todo_auth_allow(p_key text) returns boolean
language plpgsql security definer set search_path=public,pg_temp as $$
declare n integer;
begin
  insert into todo_auth_attempts(key_hash,attempts) values(p_key,1)
  on conflict(key_hash) do update set
    attempts=case when todo_auth_attempts.window_start < now()-interval '10 minutes' then 1 else todo_auth_attempts.attempts+1 end,
    window_start=case when todo_auth_attempts.window_start < now()-interval '10 minutes' then now() else todo_auth_attempts.window_start end
  returning attempts into n;
  return n<=15;
end $$;
revoke all on function public.todo_auth_allow(text) from public,anon,authenticated;
grant execute on function public.todo_auth_allow(text) to service_role;
commit;

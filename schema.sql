-- QTRS Nexus ERP: run once in Supabase > SQL Editor
create table public.profiles(id uuid primary key references auth.users(id) on delete cascade,email text,name text,role text not null default 'pending',co text not null default 'all',mods jsonb not null default '[]',active boolean not null default true,created_at timestamptz default now());
create table public.records(collection text not null,id text not null,co text,data jsonb not null,updated_at timestamptz not null default now(),updated_by uuid default auth.uid(),primary key(collection,id));
create index records_co_idx on public.records(co);
alter table public.profiles enable row level security;
alter table public.records enable row level security;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from profiles where id=auth.uid() and role='admin' and active)$$;
create or replace function public.my_co() returns text language sql stable security definer set search_path=public as $$select co from profiles where id=auth.uid() and active and role<>'pending'$$;
create or replace function public.can_write() returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from profiles where id=auth.uid() and active and role not in ('pending','viewer'))$$;
create policy rec_read on public.records for select to authenticated using (my_co() is not null and (my_co()='all' or co is null or co=my_co()));
create policy rec_ins on public.records for insert to authenticated with check (can_write() and (my_co()='all' or co=my_co()));
create policy rec_upd on public.records for update to authenticated using (can_write() and (my_co()='all' or co=my_co())) with check (can_write() and (my_co()='all' or co=my_co()));
create policy rec_del on public.records for delete to authenticated using (can_write() and (my_co()='all' or co=my_co()));
create policy prof_read on public.profiles for select to authenticated using (id=auth.uid() or is_admin());
create policy prof_upd on public.profiles for update to authenticated using (is_admin()) with check (is_admin());
-- first account to sign up becomes admin; everyone after is "pending" until an admin approves them
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
declare first_user boolean;
begin first_user := not exists(select 1 from profiles);
insert into profiles(id,email,name,role) values(new.id,new.email,coalesce(new.raw_user_meta_data->>'name',new.email),case when first_user then 'admin' else 'pending' end);
return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
alter publication supabase_realtime add table public.records;

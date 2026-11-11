-- Conecta Futuro: PostgreSQL schema, constraints, ownership and RLS.
create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null check (char_length(full_name) between 2 and 120),
  email text not null,
  phone text,
  city text not null default 'Canoinhas',
  birth_date date,
  user_type text not null default 'user' check (user_type in ('user','admin')),
  created_at timestamptz not null default now()
);

create table public.courses (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 3 and 180),
  description text not null,
  category text not null,
  modality text not null check (modality in ('online','hybrid','in_person')),
  level text not null default 'beginner',
  workload integer check (workload is null or workload > 0),
  institution text not null,
  city text not null default 'Canoinhas',
  enrollment_url text,
  status text not null default 'draft' check (status in ('draft','published','archived')),
  created_at timestamptz not null default now()
);

create table public.opportunities (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 3 and 180),
  company text not null,
  description text not null,
  category text not null,
  modality text not null check (modality in ('online','hybrid','in_person')),
  requirements text[] not null default '{}',
  city text not null default 'Canoinhas',
  application_url text,
  deadline date,
  status text not null default 'draft' check (status in ('draft','published','archived')),
  created_at timestamptz not null default now()
);

create table public.user_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  opportunity_id uuid not null references public.opportunities(id) on delete cascade,
  status text not null default 'submitted' check (status in ('submitted','in_review','interview','accepted','rejected','withdrawn')),
  created_at timestamptz not null default now(),
  unique (user_id, opportunity_id)
);

create table public.user_courses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete cascade,
  status text not null default 'enrolled' check (status in ('enrolled','in_progress','completed','cancelled')),
  created_at timestamptz not null default now(),
  unique (user_id, course_id)
);

create table public.articles (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 3 and 180),
  content text not null,
  category text not null,
  image_url text,
  status text not null default 'draft' check (status in ('draft','published','archived')),
  created_at timestamptz not null default now()
);

create table public.impact_metrics (
  id uuid primary key default gen_random_uuid(),
  metric_name text not null unique,
  metric_value numeric not null default 0 check (metric_value >= 0),
  description text not null default '',
  updated_at timestamptz not null default now()
);

create index user_applications_user_idx on public.user_applications(user_id, created_at desc);
create index user_courses_user_idx on public.user_courses(user_id, created_at desc);
create index courses_public_idx on public.courses(status, created_at desc);
create index opportunities_public_idx on public.opportunities(status, created_at desc);
create index articles_public_idx on public.articles(status, created_at desc);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles where id = (select auth.uid()) and user_type = 'admin');
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

create or replace function public.create_profile_for_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, coalesce(nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''), 'Novo usuário'), new.email);
  return new;
end;
$$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute procedure public.create_profile_for_new_user();

alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.opportunities enable row level security;
alter table public.user_applications enable row level security;
alter table public.user_courses enable row level security;
alter table public.articles enable row level security;
alter table public.impact_metrics enable row level security;

create policy "profiles select own or admin" on public.profiles for select to authenticated using (id = (select auth.uid()) or (select public.is_admin()));
create policy "profiles update own or admin" on public.profiles for update to authenticated using (id = (select auth.uid()) or (select public.is_admin())) with check (id = (select auth.uid()) or (select public.is_admin()));
-- Restrict user-editable profile columns; user_type is deliberately excluded.
grant select on public.profiles to authenticated;
grant update (full_name, phone, city, birth_date) on public.profiles to authenticated;
grant update (full_name, email, phone, city, birth_date, user_type) on public.profiles to service_role;

create policy "published courses readable" on public.courses for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "admins manage courses" on public.courses for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "published opportunities readable" on public.opportunities for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "admins manage opportunities" on public.opportunities for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "published articles readable" on public.articles for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "admins manage articles" on public.articles for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "users read own applications" on public.user_applications for select to authenticated using (user_id = (select auth.uid()) or (select public.is_admin()));
create policy "users create own applications for published opportunities" on public.user_applications for insert to authenticated with check (user_id = (select auth.uid()) and exists (select 1 from public.opportunities o where o.id = opportunity_id and o.status = 'published'));
create policy "admins update applications" on public.user_applications for update to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy "users withdraw own applications" on public.user_applications for delete to authenticated using (user_id = (select auth.uid()) and status <> 'accepted');

create policy "users read own course enrollments" on public.user_courses for select to authenticated using (user_id = (select auth.uid()) or (select public.is_admin()));
create policy "users enroll in published courses" on public.user_courses for insert to authenticated with check (user_id = (select auth.uid()) and exists (select 1 from public.courses c where c.id = course_id and c.status = 'published'));
create policy "users cancel own enrollment" on public.user_courses for delete to authenticated using (user_id = (select auth.uid()) and status in ('enrolled','cancelled'));
create policy "admins update enrollments" on public.user_courses for update to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "admins read impact metrics" on public.impact_metrics for select to authenticated using ((select public.is_admin()));
create policy "admins manage impact metrics" on public.impact_metrics for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

grant select on public.courses, public.opportunities, public.articles to anon, authenticated;
grant delete on public.user_applications, public.user_courses to authenticated;
-- Limit inserted columns so users cannot submit a fabricated application/enrollment status.
grant insert (user_id, opportunity_id) on public.user_applications to authenticated;
grant insert (user_id, course_id) on public.user_courses to authenticated;
grant select on public.user_applications, public.user_courses to authenticated;
grant update (status) on public.user_applications, public.user_courses to authenticated;
grant select, insert, update, delete on public.courses, public.opportunities, public.articles, public.impact_metrics to authenticated;

create or replace function public.get_admin_impact_summary()
returns table (metric_name text, metric_value bigint)
language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_admin() then raise exception 'admin access required' using errcode = '42501'; end if;
  return query select 'registered_users'::text, count(*) from public.profiles
    union all select 'course_enrollments'::text, count(*) from public.user_courses where status <> 'cancelled'
    union all select 'completed_courses'::text, count(*) from public.user_courses where status = 'completed'
    union all select 'job_applications'::text, count(*) from public.user_applications where status <> 'withdrawn'
    union all select 'published_courses'::text, count(*) from public.courses where status = 'published'
    union all select 'published_opportunities'::text, count(*) from public.opportunities where status = 'published';
end;
$$;
revoke all on function public.get_admin_impact_summary() from public;
grant execute on function public.get_admin_impact_summary() to authenticated;

-- Admins must be promoted manually by a trusted operator in the SQL editor:
-- update public.profiles set user_type = 'admin' where email = 'admin@example.org';

-- Verified referrals and an admin-only aggregate dashboard. All values are live DB aggregates.
create table if not exists public.referrals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  opportunity_id uuid references public.opportunities(id) on delete set null,
  status text not null default 'pending' check (status in ('pending','confirmed')),
  proof_reference text,
  confirmed_by uuid references public.profiles(id) on delete set null,
  confirmed_at timestamptz,
  created_at timestamptz not null default now(),
  constraint referral_confirmation_requires_evidence check (
    status <> 'confirmed' or
    (nullif(trim(proof_reference), '') is not null and confirmed_by is not null and confirmed_at is not null)
  )
);

create index if not exists referrals_status_idx on public.referrals(status, confirmed_at desc);
create unique index if not exists referrals_proof_reference_unique
  on public.referrals (lower(trim(proof_reference))) where proof_reference is not null;
alter table public.referrals enable row level security;
drop policy if exists "admins manage referrals" on public.referrals;
create policy "admins manage referrals" on public.referrals for all to authenticated
  using ((select public.is_admin())) with check ((select public.is_admin()));
grant select, insert, update, delete on public.referrals to authenticated;

create or replace function public.get_admin_impact_dashboard()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare dashboard jsonb;
begin
  if not public.is_admin() then raise exception 'admin access required' using errcode = '42501'; end if;

  select jsonb_build_object(
    'source', 'live_postgresql',
    'generated_at', now(),
    'totals', jsonb_build_object(
      'users', (select count(*) from public.profiles),
      'courses', (select count(*) from public.courses where status = 'published'),
      'course_enrollments', (select count(*) from public.user_courses where status <> 'cancelled'),
      'opportunities_registered', (select count(*) from public.opportunities),
      'opportunities_available', (select count(*) from public.opportunities where status = 'published'),
      'applications', (select count(*) from public.user_applications),
      'confirmed_referrals', (select count(*) from public.referrals where status = 'confirmed' and proof_reference is not null)
    ),
    'users_by_month', coalesce((
      select jsonb_agg(jsonb_build_object('period', to_char(m.month_start, 'YYYY-MM'), 'value', coalesce(x.value, 0)) order by m.month_start)
      from generate_series(date_trunc('month', now()) - interval '11 months', date_trunc('month', now()), interval '1 month') as m(month_start)
      left join (select date_trunc('month', created_at) as month_start, count(*) as value from public.profiles group by 1) x using (month_start)
    ), '[]'::jsonb),
    'enrollments_by_month', coalesce((
      select jsonb_agg(jsonb_build_object('period', to_char(m.month_start, 'YYYY-MM'), 'value', coalesce(x.value, 0)) order by m.month_start)
      from generate_series(date_trunc('month', now()) - interval '11 months', date_trunc('month', now()), interval '1 month') as m(month_start)
      left join (select date_trunc('month', created_at) as month_start, count(*) as value from public.user_courses where status <> 'cancelled' group by 1) x using (month_start)
    ), '[]'::jsonb),
    'applications_by_month', coalesce((
      select jsonb_agg(jsonb_build_object('period', to_char(m.month_start, 'YYYY-MM'), 'value', coalesce(x.value, 0)) order by m.month_start)
      from generate_series(date_trunc('month', now()) - interval '11 months', date_trunc('month', now()), interval '1 month') as m(month_start)
      left join (select date_trunc('month', created_at) as month_start, count(*) as value from public.user_applications group by 1) x using (month_start)
    ), '[]'::jsonb),
    'opportunities_by_category', coalesce((
      select jsonb_agg(jsonb_build_object('label', category, 'value', value) order by value desc, category)
      from (select category, count(*) as value from public.opportunities where status = 'published' group by category) c
    ), '[]'::jsonb),
    'opportunities_by_city', coalesce((
      select jsonb_agg(jsonb_build_object('label', city, 'value', value) order by value desc, city)
      from (select city, count(*) as value from public.opportunities where status = 'published' group by city) c
    ), '[]'::jsonb)
  ) into dashboard;

  return dashboard;
end;
$$;
revoke all on function public.get_admin_impact_dashboard() from public;
grant execute on function public.get_admin_impact_dashboard() to authenticated;

import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const read = (path) => readFile(resolve(root, path), "utf8");
const schema = await read("supabase/migrations/202611040001_initial_schema.sql");
const impact = await read("supabase/migrations/202611040002_impact_dashboard.sql");

test("required data tables are declared and protected by RLS", () => {
  for (const table of ["profiles", "courses", "opportunities", "user_applications", "user_courses", "articles", "impact_metrics"]) {
    assert.match(schema, new RegExp(`create table public\\.${table}\\s*\\(`, "i"), `${table} table exists`);
    assert.match(schema, new RegExp(`alter table public\\.${table} enable row level security`, "i"), `${table} RLS is enabled`);
  }
  assert.match(impact, /create table if not exists public\.referrals/i);
  assert.match(impact, /alter table public\.referrals enable row level security/i);
});

test("ordinary users cannot self-promote and enrollment/application ownership is checked", () => {
  assert.match(schema, /user_type text not null default 'user'/i);
  assert.match(schema, /grant update \(full_name, phone, city, birth_date\) on public\.profiles to authenticated/i);
  assert.doesNotMatch(schema, /grant update \([^)]*user_type[^)]*\) on public\.profiles to authenticated/i);
  assert.match(schema, /user_id = \(select auth\.uid\(\)\)/i);
  assert.match(schema, /status = 'published'/i);
});

test("admin-only impact aggregation requires verified referral references", () => {
  assert.match(impact, /if not public\.is_admin\(\) then raise exception/i);
  assert.match(impact, /status = 'confirmed' and proof_reference is not null/i);
  assert.match(impact, /users_by_month/i);
  assert.match(impact, /enrollments_by_month/i);
  assert.match(impact, /applications_by_month/i);
  assert.match(impact, /opportunities_by_category/i);
  assert.match(impact, /opportunities_by_city/i);
});

test("public environment template contains only public Supabase credentials", async () => {
  const env = await read(".env.example");
  assert.match(env, /^NEXT_PUBLIC_SUPABASE_URL=/m);
  assert.match(env, /^NEXT_PUBLIC_SUPABASE_ANON_KEY=/m);
  assert.doesNotMatch(env, /service[_-]?role|secret|password/i);
});

test("protected routes fail closed when Supabase is not configured", async () => {
  const middleware = await read("src/middleware.ts");
  assert.match(middleware, /if \(!url \|\| !key\)/);
  assert.match(middleware, /pathname\.startsWith\("\/painel"\).*pathname\.startsWith\("\/admin"\)/s);
  assert.match(middleware, /supabase-indisponivel/);
  assert.match(middleware, /pathname\.startsWith\("\/admin"\) && user/);
});

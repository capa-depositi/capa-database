# Supabase Setup Instructions — App Hub Schemas Migration

This document explains how to create the new PostgreSQL schema structure inside your existing
Supabase project, replacing the flat MySQL `users / lists / items / list_items` layout with a
multi-schema structure split by application, as described in
[PERSONAL_APP_HUB_ARCHITECTURE_UPDATED.md](../PERSONAL_APP_HUB_ARCHITECTURE_UPDATED.md).

## 1. New structure overview

```text
personal_apps (your existing Supabase Postgres database)
├── hub          -> App Hub: identity, app registry, access control
│   ├── users
│   ├── apps
│   └── user_apps
└── shopping     -> Todolist app: domain data
    ├── items
    ├── lists
    └── list_items
```

Ownership rule: `hub` owns users and app access; `shopping` owns todolist data and references
`hub.users` via foreign key. Old MySQL `users` table becomes `hub.users`; old `lists`, `items`,
`list_items` become `shopping.*`.

## 2. Migration files

The SQL to create this structure is in [supabase/migrations](../supabase/migrations):

- `0001_create_schemas.sql` — creates the `hub` and `shopping` schemas.
- `0002_hub_tables.sql` — creates `hub.users`, `hub.apps`, `hub.user_apps`, and seeds a `shopping`
  row in `hub.apps` so users can be granted access to the todolist app.
- `0003_shopping_tables.sql` — creates `shopping.items`, `shopping.lists`, `shopping.list_items`,
  indexes, and an `updated_at` trigger (Postgres has no `ON UPDATE CURRENT_TIMESTAMP`).

Run them **in order** — later files depend on schemas/tables created earlier.

Additional migrations for this repository

- `0001_capa_init.sql` — CAPA project schema (profiles, questions, answers, legal_rates, result_tokens).
  File path: `supabase/migrations/0001_capa_init.sql` in this repository. This migration was generated
  from the project's SQLite schema and backend code and targets PostgreSQL/Supabase.

Seeding notes for CAPA

- The repository includes SQL migrations for CAPA under `database/migrations/` (e.g. `0004_capa_init.sql`
  and `0005_capa_seed.sql`). The `backend/scripts/init-db.js` script has been updated to apply these SQL
  migrations (including seed inserts) directly to Postgres; the previous JSON seed files have been
  removed from the repository. For Supabase, copy the SQL migration files into `supabase/migrations/`
  (or keep them under `database/migrations/` and copy before running the CLI) and run `supabase db push`
  so schema and seed SQL are applied in order.

## 3. Apply the migrations to Supabase

### Option A — Supabase Dashboard SQL editor (quickest)

1. Open your Supabase project → **SQL Editor**.
2. Open `0001_create_schemas.sql`, paste its contents, click **Run**.
3. Repeat for `0002_hub_tables.sql`, then `0003_shopping_tables.sql`.

### Option B — Supabase CLI (recommended for version control)

```bash
npm install -g supabase
supabase login
supabase link --project-ref <your-project-ref>
supabase db push
```

`supabase db push` applies every `.sql` file in `supabase/migrations` that hasn't been applied yet,
in filename order — this is why the files are numbered.

## 4. Expose the `hub` and `shopping` schemas via the API (if needed)

By default, Supabase's auto-generated REST API only exposes the `public` schema. If you plan to
query `hub.*` / `shopping.*` tables through `supabase-js` directly (instead of only through your
own backend with `pg`), expose them:

1. Dashboard → **Project Settings → API → Exposed schemas**.
2. Add `hub` and `shopping` to the list.
3. Grant privileges to the API roles, e.g. in the SQL editor:

```sql
GRANT USAGE ON SCHEMA hub, shopping TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA hub TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA shopping TO authenticated, service_role;
```

If your backend keeps talking to Postgres directly via `pg` (as the current `db.js` does with
`mysql2`), this step is optional — schema exposure only matters for the PostgREST/`supabase-js` API.

## 5. Data migration from MySQL

Once the empty schema is verified in Supabase:

1. Export data from MySQL per table (`items`, `lists`, `list_items`, `users`).
2. Insert into the matching new table:
   - MySQL `users` → `hub.users`
   - MySQL `items` → `shopping.items`
   - MySQL `lists` → `shopping.lists`
   - MySQL `list_items` → `shopping.list_items`
3. Preserve original IDs so foreign keys (`shopping.lists.user_id`,
   `shopping.list_items.list_id/item_id`) stay valid. If you insert with explicit IDs into an
   `IDENTITY` column, reset the sequence afterwards, e.g.:

```sql
SELECT setval(pg_get_serial_sequence('hub.users', 'id'), (SELECT MAX(id) FROM hub.users));
```

Repeat for `hub.apps`, `shopping.items`, `shopping.lists`, `shopping.list_items`.

4. For every migrated user, grant shopping app access:

```sql
INSERT INTO hub.user_apps (user_id, app_id, enabled)
SELECT u.id, a.id, true
FROM hub.users u, hub.apps a
WHERE a.slug = 'shopping';
```

## 6. Update the backend connection layer

`backend/utils/db.js` currently uses `mysql2`. It needs to move to `pg`, and every query needs:

- `users` → `hub.users`, `lists` → `shopping.lists`, `items` → `shopping.items`,
  `list_items` → `shopping.list_items`.
- `?` placeholders → `$1, $2, ...`.
- MySQL-specific syntax (e.g. `LIMIT ?, ?`) → Postgres syntax (`LIMIT $1 OFFSET $2`).

This is a separate follow-up step from the schema creation covered by this document.

## 7. Verification checklist

- [ ] `hub` and `shopping` schemas exist in Supabase (Table Editor → schema dropdown).
- [ ] `hub.users`, `hub.apps`, `hub.user_apps` created with correct columns/constraints.
- [ ] `shopping.items`, `shopping.lists`, `shopping.list_items` created with correct FKs.
- [ ] `hub.apps` contains the seeded `shopping` row.
- [ ] Row counts after data migration match the original MySQL tables.
- [ ] Foreign keys resolve (no orphaned `list_items.list_id`/`item_id`, no orphaned `lists.user_id`).
- [ ] Backend connection layer updated and the app works end-to-end against Supabase Postgres.

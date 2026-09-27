# Supabase Quick Setup — CAPA

This short summary lists the minimal steps to apply the repository SQL migrations and seed data to a Supabase (Postgres) project.

1) Create a Supabase project
- Create a project in the Supabase dashboard and note the `PROJECT_REF` and connection string.

2) Install & authenticate the Supabase CLI
- Install (see Supabase docs):

  ```bash
  npm install -g supabase
  # or (macOS Homebrew)
  # brew install supabase/tap/supabase
  ```

- Login & link to the project:

  ```bash
  supabase login
  supabase link --project-ref <PROJECT_REF>
  ```

3) Prepare migrations (two options)
- Option A — copy migrations into `supabase/migrations`:

  ```bash
  mkdir -p supabase/migrations
  cp database/*.sql supabase/migrations/
  ```

  (PowerShell: `mkdir supabase\migrations; copy database\*.sql supabase\migrations\`)

- Option B — tell the CLI to use the repo `database/` folder by creating `supabase/config.toml` with:

  ```toml
  [migrations]
  directory = "database"
  ```

  (Either copy files or configure `migrations.directory`; both work.)

4) Push migrations to Supabase

```bash
supabase db push
```

This applies the SQL files in filename (sorted) order. The repo includes `0001_capa_init.sql` and `0002_capa_seed.sql`.

5) Verify the database
- Use Supabase SQL editor or `psql`:

```bash
psql "$DATABASE_URL" -c "SELECT count(*) FROM questions;"
```

- Or run the repository inspector:

```bash
cd backend
npm run inspect-db
```

6) Configure backend to use Supabase DB
- Set `DATABASE_URL` in `database/.env` (do NOT commit secrets) or in your host/CI secrets.
- Example `.env` (local/test):

```text
DATABASE_URL=postgresql://<user>:<password>@<host>:5432/<database>
```

7) CI / Deployment
- In CI set `DATABASE_URL` as a secret and either run `supabase db push` or run `node backend/scripts/init-db.js` to apply SQL.

8) Ongoing migrations & seeds
- Keep canonical SQL migrations in `database/` with a numeric/timestamp prefix (e.g., `0003_add_column.sql`).
- Seeds in SQL should be idempotent (use `ON CONFLICT DO NOTHING`) as in `0002_capa_seed.sql`.

9) Troubleshooting
- If `supabase db push` errors due to existing objects, inspect the DB with the SQL editor or `psql` and resolve conflicts.
- Ensure migration filenames are unique and ordered.

Notes
- The repository now treats `database/` as the canonical migration/seed folder.
- Local SQLite files were removed from the repo and are ignored (`.gitignore`).

---

If you want, I can also copy the SQL files to `supabase/migrations/` and run `supabase db push` for you if you provide the `PROJECT_REF` and approve running the CLI.
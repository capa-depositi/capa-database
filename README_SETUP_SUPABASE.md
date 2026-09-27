# Supabase setup for CAPA

This document describes ordered steps to set up the CAPA database on Supabase (Postgres), plus safe cleanup of legacy local SQLite files.

## Prerequisites
- Supabase CLI installed and you have a Supabase project (see https://supabase.com/docs/guides/cli).
- Node.js and `npm` available to run backend scripts locally.
- A valid `DATABASE_URL` (Supabase connection string) for your project.

## Important files (keep)
- `database/migrations/0001_capa_init.sql` — schema migration (canonical).
- `database/migrations/0002_capa_seed.sql` — seed SQL (canonical).
- `database/README_SCHEMA.md` — schema summary.
- `backend/scripts/init-db.js` — local initializer that applies SQL migrations from `database/migrations`.
- `database/.env` — local placeholder for `DATABASE_URL` (DO NOT commit secrets).

## Files safe to remove (after verification & backup)
- database/capa.db
- database/capa.db-shm
- database/capa.db-wal

These are local SQLite files used during development. Keep a backup copy before deleting.

## Quick checklist
1. Set your `DATABASE_URL` in `database/.env` or export it in your shell.
2. Choose one of two workflows below to populate the database:
   - Option A (recommended): Use Supabase CLI migrations.
   - Option B: Run the local `init-db` script to create & seed the DB directly.
3. Verify tables and seed data.
4. Remove legacy SQLite files once verified and add `.gitignore` entries.

## Option A — Using Supabase CLI (recommended for remote project)
1. Login and link your repository to the remote project:

   ```bash
   supabase login
   supabase link --project-ref <PROJECT_REF>
   ```

2. Prepare migrations for the Supabase CLI. The Supabase CLI expects migrations in `supabase/migrations/` by default. You have two choices:

- Copy the repository migrations into the Supabase migrations folder (recommended):

   ```bash
   mkdir -p supabase/migrations
   cp database/* supabase/migrations/
   ```

   On Windows PowerShell:

   ```powershell
   mkdir supabase\migrations; copy database\* supabase\migrations\
   ```

- Or configure `config.toml` to point to the `database/` directory (the repo already includes `database/config.toml`), then the CLI can use the existing folder without copying.

3. Push migrations to the remote DB:

   ```bash
   supabase db push
   ```

   This will apply schema + seed SQL files in order (filename order).

4. Verify the remote DB (see Verification below).

Notes:
- If the CLI complains about migration filenames, ensure each migration filename is unique and ordered.

## Option B — Local initializer script (useful for local testing or CI)
1. Put your production `DATABASE_URL` into `database/.env` (or export the env var).

   Example `.env` content:
   ```text
   DATABASE_URL=postgresql://<user>:<password>@<host>:5432/<database>?sslmode=require
   ```

2. From repo root, run the initializer:

   ```bash
   cd backend
   npm install
   npm run init-db
   ```

   Or, set the env var and run directly:

   Linux/macOS:
   ```bash
   export DATABASE_URL='postgresql://user:pass@host:5432/dbname'
   cd backend
   node scripts/init-db.js
   ```

   Windows PowerShell:
   ```powershell
   $env:DATABASE_URL='postgresql://user:pass@host:5432/dbname'
   cd backend
   node scripts/init-db.js
   ```

3. The script will apply SQL migrations from `database/migrations/` (including seed SQL).

## Seeding strategy
- Seeds are stored as SQL migration(s) in `database/migrations/0002_capa_seed.sql` and are applied by the initializer or by `supabase db push`.

## Verification
- Quick SQL checks using `psql` (if installed):

  ```bash
  psql "$DATABASE_URL" -c "SELECT count(*) FROM questions;"
  psql "$DATABASE_URL" -c "SELECT count(*) FROM legal_rates;"
  ```

- Use the provided inspector script:

  ```bash
  cd backend
  npm run inspect-db
  ```

- Or run simple queries in Supabase SQL editor.

## Cleanup — removing local SQLite files
1. Backup first:
   - Copy `database/capa.db` somewhere safe (compress it off-repo).
2. Remove from repository and disk (once confirmed):

   ```bash
   git rm --cached database/capa.db || true
   rm -f database/capa.db database/capa.db-shm database/capa.db-wal
   ```

   (On Windows use `del` or File Explorer.)

3. Add ignore rules (recommended `.gitignore` additions):

   ```text
   /database/.env
   /database/capa.db
   /database/capa.db-shm
   /database/capa.db-wal
   /supabase/cred.txt
   ```

## CI / Deployment notes
- In CI (GitHub Actions, Vercel, etc.) set `DATABASE_URL` as a secret and run either `supabase db push` (if you keep a supabase project layout) or `node backend/scripts/init-db.js` as part of deployment.
- Never store production credentials in the repository.

## Troubleshooting tips
- Duplicate migration numbers: rename migrations to unique, ordered filenames (timestamps are safe).
- If `supabase db push` fails with conflicts, use the SQL editor in the Supabase dashboard to inspect and resolve.

## Summary — what you can remove now (after backup & verification)
- `database/capa.db`
- `database/capa.db-shm`
- `database/capa.db-wal`

Leave migrations in place in `database/migrations/`.

---
If you want, I can now:
- delete the three SQLite files (make a backup first),
- add the recommended `.gitignore` entries, or
- copy `database/migrations/*` into `supabase/migrations/` and run `supabase db push` if you provide the project-ref.

Tell me which of the three actions you'd like me to take next.
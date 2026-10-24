# CAPA database setup

The CAPA PostgreSQL schema baseline and seed data are in this directory:

- `0001_capa_init.sql` creates the schema, including profiles, submissions, answers, and result tokens.
- `0002_capa_seed.sql` adds questionnaire questions and legal interest rates.
- `README_SCHEMA.md` summarizes the tables.

The backend initializer uses the same connection configuration as the backend: `capa-backend/.env` takes precedence, with `capa-database/.env` as fallback. It applies the SQL files in this directory in filename order:

```powershell
Set-Location capa-backend
npm run init-db
```

## Resetting the development database

The baseline describes the current schema; it does not convert the former profile-scoped answers schema. Since current records are test data, reset the CAPA tables in the development Supabase project before initializing the new schema.

Before running the SQL below, verify the project in the Supabase dashboard is the development project. This deletes all CAPA profiles, submissions, answers, tokens, questions, and rates in that project's `public` schema. Do not run it against production or a database containing data that must be retained.

Run in the Supabase SQL Editor:

```sql
DROP TABLE IF EXISTS result_tokens, answers, questionnaire_submissions, profiles, questions, legal_rates CASCADE;
```

Then ensure the backend and initializer point to the intended development database (`capa-backend/.env` takes precedence over `capa-database/.env`) and run `npm run init-db` from `capa-backend`. The initializer recreates the schema and seeds questions and rates.

The initializer is repeatable for the current schema because the SQL uses `IF NOT EXISTS` and seed inserts use `ON CONFLICT`. It is not a schema migration runner: editing the baseline does not modify tables that already exist, so reset the development schema first.

## Verification

After initialization, verify the expected tables and seed counts in the Supabase SQL Editor, or run the backend inspector:

```powershell
Set-Location capa-backend
npm run inspect-db
```

Keep credentials in the ignored local `.env` file and never commit them. Do not use a production connection string for initialization or reset.

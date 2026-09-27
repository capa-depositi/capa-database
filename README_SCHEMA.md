# CAPA Database Schema - Summary

This document summarizes the CAPA project's database schema and the generated Supabase/PostgreSQL migration.

Files generated:
- `database/0001_capa_init.sql` - PostgreSQL-compatible migration created from the project's previous SQLite schema and backend code.

Tables (brief):
- `profiles` — user profiles (UUID id, nome, cognome, eta, email, ruolo, created_at)
- `answers` — questionnaire answers (one per question per profile, unique constraint)
- `questions` — question catalog (select options stored as text/JSON)
- `legal_rates` — per-year legal interest rates
- `result_tokens` — email tokens to revisit results (hashed token, expiry, view count)

Notes:
The codebase now uses PostgreSQL (Supabase) and migrations in `database/`.
The migration uses PostgreSQL types and constraints; ensure `DATABASE_URL` is set for `backend/scripts/init-db.js`.
Seed data (questions and `legal_rates`) is provided via `database/0002_capa_seed.sql`.

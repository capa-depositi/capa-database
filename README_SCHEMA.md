# CAPA Database Schema - Summary

This document summarizes the CAPA project's Supabase/PostgreSQL schema.

Schema setup:
- `0001_capa_init.sql` - PostgreSQL schema baseline.
- `0002_capa_seed.sql` - question and legal-rate seed data.

Tables (brief):
- `profiles` — user profiles (UUID id, nome, cognome, eta, email, ruolo, created_at)
- `questionnaire_submissions` — each questionnaire attempt, its completion state, and recap-email status
- `answers` — questionnaire answers (one per question per submission, unique constraint)
- `questions` — question catalog (select options stored as text/JSON)
- `legal_rates` — per-year legal interest rates
- `result_tokens` — submission-specific email tokens to revisit results (hashed token, expiry, view count)

Notes:
The backend initializer applies the SQL files in this directory. A submission is complete only when Q4 is `"Sì"` and every required applicable question has an answer. Q4 = `"No"` stays incomplete and does not trigger a recap email.

Results are recalculated from the selected submission's answers whenever viewed. The schema stores answers and result-link tokens per submission, not a result snapshot.

The schema baseline targets a clean development database; it does not alter an existing profile-scoped schema. For the test environment, reset the database before initializing, then apply the seed data. See [README_SETUP_SUPABASE.md](./README_SETUP_SUPABASE.md).

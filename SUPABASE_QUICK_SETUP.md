# CAPA Supabase quick setup

CAPA's current schema and seed files live in this directory. Follow [README_SETUP_SUPABASE.md](./README_SETUP_SUPABASE.md) for the clean-development-database setup and reset instructions.

The backend initializer uses the backend's connection configuration (`capa-backend/.env` first, then `capa-database/.env`) and applies `0001_capa_init.sql` followed by `0002_capa_seed.sql`. This is a schema baseline for a clean test database, not an incremental migration workflow.

Before any reset, verify in the Supabase dashboard that the selected project is the development project. Never use the documented reset process with a production connection.

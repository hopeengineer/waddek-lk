-- Enable required Postgres extensions for Waddek.lk
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";       -- trigram text search on job titles
CREATE EXTENSION IF NOT EXISTS "moddatetime";   -- auto-update updated_at columns
CREATE EXTENSION IF NOT EXISTS "pgcrypto";      -- for gen_random_uuid (usually already enabled)

-- ═══════════════════════════════════════════════════════════════
-- Auto-create profile row for every auth.users insert.
--
-- Today, profile rows are only created by the client `register()`
-- upsert in lib/features/auth/data/auth_repository.dart. Any user
-- created outside that flow (manually in the dashboard, via
-- auth.admin.createUser, etc.) ends up authenticated with no profile
-- row, which breaks every screen that reads `profiles`.
--
-- This migration adds:
--   1. fn_handle_new_auth_user() — SECURITY DEFINER inserter
--   2. AFTER INSERT trigger on auth.users
--   3. Backfill INSERT for existing orphaned auth users
--
-- `register()` continues to work unchanged because the upsert uses
-- the same primary key and we ON CONFLICT DO NOTHING here.
-- ═══════════════════════════════════════════════════════════════

BEGIN;

CREATE OR REPLACE FUNCTION fn_handle_new_auth_user()
RETURNS TRIGGER AS $$
BEGIN
  -- profiles.phone is NOT NULL, but a manually-created email-only
  -- auth user may have NULL phone — fall back to '' so the row
  -- can still be created and the user can add a phone later.
  INSERT INTO profiles (id, phone, email)
  VALUES (NEW.id, COALESCE(NEW.phone, ''), NEW.email)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_auth_user_create_profile ON auth.users;
CREATE TRIGGER trg_auth_user_create_profile
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION fn_handle_new_auth_user();

-- Heal any auth.users that don't have a profile row yet.
INSERT INTO profiles (id, phone, email)
SELECT u.id, COALESCE(u.phone, ''), u.email
FROM auth.users u
LEFT JOIN profiles p ON p.id = u.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;

COMMIT;

-- ═══════════════════════════════════════════════════════════════
-- Shufti Pro identity verification + duplicate detection + Pro badge.
--
-- Adds:
--   * id_doc_type enum (nic / driving_licence / passport)
--   * id_doc_hash for cross-account dedup (sha256(type || '|' || number))
--   * date_of_birth + age in public_profiles (DOB never exposed)
--   * gender, nationality (read from ID, locked on verify)
--   * verification attempt counter + cooldown for cost control
--   * identity_locked flag enforced via BEFORE UPDATE trigger
--   * 'duplicate_detected' verification_status branch + recovery target
--   * is_pro computed boolean in public_profiles (driven by active subscription)
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ── Enum extensions ─────────────────────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'id_doc_type') THEN
    CREATE TYPE id_doc_type AS ENUM ('nic', 'driving_licence', 'passport');
  END IF;
END $$;

-- verification_status: add 'duplicate_detected' for the dedup branch.
-- ALTER TYPE ... ADD VALUE must run outside a transaction in pg < 12,
-- but Supabase runs pg 15+ which allows it inside.
ALTER TYPE verification_status ADD VALUE IF NOT EXISTS 'duplicate_detected';

-- ── Profile columns ─────────────────────────────────────────────
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS id_doc_type id_doc_type,
  ADD COLUMN IF NOT EXISTS id_doc_hash text,
  ADD COLUMN IF NOT EXISTS date_of_birth date,
  ADD COLUMN IF NOT EXISTS gender text,
  ADD COLUMN IF NOT EXISTS nationality text,
  ADD COLUMN IF NOT EXISTS shuftipro_reference text,
  ADD COLUMN IF NOT EXISTS shuftipro_decline_reason text,
  ADD COLUMN IF NOT EXISTS duplicate_target_user_id uuid
    REFERENCES profiles(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS verification_attempts int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS verification_locked_until timestamptz,
  ADD COLUMN IF NOT EXISTS identity_locked boolean NOT NULL DEFAULT false;

-- Dedup index. Partial so multiple unverified profiles (NULL hash)
-- can coexist. Two verified accounts with the same hash is impossible.
CREATE UNIQUE INDEX IF NOT EXISTS uniq_profiles_id_doc_hash
  ON profiles (id_doc_hash) WHERE id_doc_hash IS NOT NULL;

-- ── Identity-lock guard ─────────────────────────────────────────
-- Once identity_locked = true, name / gender / nationality / DOB are
-- frozen for in-app updates. Only the service_role (used by the
-- shuftipro-callback edge function and the recover-account-by-id flow)
-- can mutate these fields, e.g. to re-bind them during recovery.
CREATE OR REPLACE FUNCTION fn_guard_locked_identity()
RETURNS TRIGGER AS $$
DECLARE
  claim_role text;
BEGIN
  -- request.jwt.claims is set by PostgREST. Edge functions hitting
  -- PostgREST with the service_role key carry role=service_role here.
  -- Migrations run as the postgres role with no JWT claims — allow.
  BEGIN
    claim_role := current_setting('request.jwt.claims', true)::jsonb->>'role';
  EXCEPTION WHEN OTHERS THEN
    claim_role := NULL;
  END;

  IF claim_role = 'service_role' OR claim_role IS NULL THEN
    RETURN NEW;
  END IF;

  IF OLD.identity_locked AND (
       NEW.full_name     IS DISTINCT FROM OLD.full_name
    OR NEW.gender        IS DISTINCT FROM OLD.gender
    OR NEW.nationality   IS DISTINCT FROM OLD.nationality
    OR NEW.date_of_birth IS DISTINCT FROM OLD.date_of_birth
    OR NEW.id_doc_type   IS DISTINCT FROM OLD.id_doc_type
    OR NEW.id_doc_hash   IS DISTINCT FROM OLD.id_doc_hash
  ) THEN
    RAISE EXCEPTION 'Identity fields are locked after verification.'
      USING ERRCODE = 'check_violation';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_guard_locked_identity ON profiles;
CREATE TRIGGER trg_guard_locked_identity
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION fn_guard_locked_identity();

-- ── public_profiles view: add age, gender, nationality, is_pro ──
-- Bypasses profiles RLS (security_invoker=off) per the earlier
-- 20260515_definer_rpcs_for_cross_user_reads migration; only the
-- columns selected here are exposed. DOB is NEVER selected — we
-- compute age from it server-side.
DROP VIEW IF EXISTS public_profiles;
CREATE VIEW public_profiles AS
  SELECT
    p.id,
    p.full_name,
    p.avatar_url,
    p.role,
    p.tier,
    p.bio,
    p.is_online,
    p.average_rating,
    p.jobs_completed_count,
    p.verification_status,
    p.preferred_locale,
    p.active_role,
    p.created_at,
    p.gender,
    p.nationality,
    CASE WHEN p.date_of_birth IS NOT NULL
      THEN EXTRACT(YEAR FROM age(p.date_of_birth))::int
      ELSE NULL
    END AS age,
    EXISTS (
      SELECT 1 FROM subscriptions s
      WHERE s.user_id = p.id
        AND s.status = 'active'
        AND s.current_period_end > now()
    ) AS is_pro
  FROM profiles p;

ALTER VIEW public_profiles SET (security_invoker = off);
GRANT SELECT ON public_profiles TO anon, authenticated;

COMMIT;

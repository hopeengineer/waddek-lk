-- ═══════════════════════════════════════════════════════════════
-- Waddek.lk — Tighten RLS visibility
--
-- The original RLS policies in 00004_create_rls_policies.sql exposed
-- the entire `profiles` table (including phone/NIC) and the entire
-- `jobs` table (including drafts) to any authenticated user via
-- `SELECT USING (true)`. This migration replaces those with
-- least-privilege variants and adds a `public_profiles` view that
-- the search/discovery flows should use instead of `profiles`.
--
-- DO NOT APPLY UNTIL the Flutter app has been switched to read from
-- `public_profiles` for any cross-user lookups. Otherwise customer
-- screens that today fetch `profiles.phone` for the matched worker
-- will start returning NULL.
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ── Profiles ─────────────────────────────────────────────────
-- Replace the "viewable by everyone" SELECT policy with a view
-- that exposes only non-sensitive columns.
DROP POLICY IF EXISTS "Profiles: viewable by everyone" ON profiles;

CREATE POLICY "Profiles: owner can read own"
  ON profiles FOR SELECT USING (auth.uid() = id);

-- Counterparty in a job or active conversation can read the row.
CREATE POLICY "Profiles: counterparty can read"
  ON profiles FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM jobs j
      WHERE (j.customer_id = auth.uid() AND j.matched_worker_id = profiles.id)
         OR (j.matched_worker_id = auth.uid() AND j.customer_id = profiles.id)
    )
    OR EXISTS (
      SELECT 1 FROM conversations c
      WHERE c.customer_id = auth.uid() AND c.worker_id = profiles.id
         OR c.worker_id = auth.uid() AND c.customer_id = profiles.id
    )
  );

-- Public discovery view: marketing surface for search / category
-- browsing. Excludes phone, email, NIC, push token.
CREATE OR REPLACE VIEW public_profiles AS
  SELECT
    id,
    full_name,
    avatar_url,
    role,
    tier,
    bio,
    is_online,
    average_rating,
    jobs_completed_count,
    verification_status,
    preferred_locale,
    active_role,
    created_at
  FROM profiles;

GRANT SELECT ON public_profiles TO anon, authenticated;

-- ── Jobs ─────────────────────────────────────────────────────
-- Drafts must not be visible to anyone but the owner. Workers
-- should only see jobs in their broadcast radius (handled at the
-- query level via the find_nearby_workers RPC), but at the RLS
-- level we restrict by status + role.
DROP POLICY IF EXISTS "Jobs: viewable by everyone" ON jobs;

CREATE POLICY "Jobs: owner can read own"
  ON jobs FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "Jobs: matched worker can read"
  ON jobs FOR SELECT USING (auth.uid() = matched_worker_id);

-- Open-to-bid jobs are visible to all authenticated users so that
-- the worker list can show them. (Geo filtering happens in the
-- query layer, not RLS.)
CREATE POLICY "Jobs: open jobs visible to authenticated"
  ON jobs FOR SELECT TO authenticated
  USING (status IN ('broadcast', 'bidding'));

-- ── OTP Codes ────────────────────────────────────────────────
-- No user-facing policies — managed entirely by Edge Functions
-- using the service_role key. Confirm RLS is enabled (already in
-- 00004) and add a deny-everything fallback for clarity.
-- (Postgres RLS denies by default with no permissive policy.)

COMMIT;

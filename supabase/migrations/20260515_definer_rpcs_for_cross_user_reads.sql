-- ═══════════════════════════════════════════════════════════════
-- SECURITY DEFINER RPCs so cross-user reads keep working under the
-- tightened profiles RLS introduced in 20260515_tighten_rls_visibility.
--
-- Why this is needed:
--   The new profiles policies allow SELECT only to the owner or a
--   counterparty (matched job / open conversation). Several pre-
--   existing client queries — bid lists, available-jobs feeds, and
--   reviewer rows — read profile fields for users who aren't yet a
--   counterparty. Those joins now silently drop rows or return nulls.
--
-- Approach:
--   1. Flip `public_profiles` to security_invoker = off so direct
--      reads of the view bypass profiles RLS but expose ONLY the
--      safe columns the view projects (no phone / email / NIC).
--   2. Add three SECURITY DEFINER RPCs that return the joined rows
--      the client used to fetch with `profiles!fk(...)` joins,
--      embedding the public worker / customer / reviewer fields as
--      a jsonb object that the existing freezed models already parse.
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ── 1. public_profiles view bypasses profiles RLS ───────────────
-- Postgres 15+ syntax. Set explicitly even if already set.
ALTER VIEW public_profiles SET (security_invoker = off);
GRANT SELECT ON public_profiles TO authenticated, anon;

-- ── 2. Bids on a job, with public worker fields ─────────────────
CREATE OR REPLACE FUNCTION get_job_bids_with_workers(p_job_id uuid)
RETURNS TABLE (
  id uuid,
  job_id uuid,
  worker_id uuid,
  amount numeric,
  message text,
  status text,
  is_unlocked boolean,
  created_at timestamptz,
  updated_at timestamptz,
  worker jsonb
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    b.id,
    b.job_id,
    b.worker_id,
    b.amount,
    b.message,
    b.status::text,
    b.is_unlocked,
    b.created_at,
    b.updated_at,
    jsonb_build_object(
      'id', p.id,
      'full_name', p.full_name,
      'avatar_url', p.avatar_url,
      'tier', p.tier::text,
      'average_rating', p.average_rating,
      'jobs_completed_count', p.jobs_completed_count,
      'verification_status', p.verification_status::text
    ) AS worker
  FROM bids b
  LEFT JOIN profiles p ON p.id = b.worker_id
  WHERE b.job_id = p_job_id
  ORDER BY b.created_at DESC;
$$;
GRANT EXECUTE ON FUNCTION get_job_bids_with_workers(uuid) TO authenticated;

-- ── 3. Available jobs for a worker, with public customer fields ─
CREATE OR REPLACE FUNCTION get_available_jobs_for_worker(
  p_worker_id uuid,
  p_category_ids uuid[]
)
RETURNS TABLE (
  id uuid,
  customer_id uuid,
  category_id uuid,
  title text,
  description text,
  address text,
  budget_min numeric,
  budget_max numeric,
  status text,
  matched_worker_id uuid,
  scheduled_at timestamptz,
  photo_urls text[],
  broadcast_radius_km int,
  latitude double precision,
  longitude double precision,
  created_at timestamptz,
  updated_at timestamptz,
  customer jsonb,
  category jsonb
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    j.id,
    j.customer_id,
    j.category_id,
    j.title,
    j.description,
    j.address,
    j.budget_min,
    j.budget_max,
    j.status::text,
    j.matched_worker_id,
    j.scheduled_at,
    j.photo_urls,
    j.broadcast_radius_km,
    ST_Y(j.location::geometry) AS latitude,
    ST_X(j.location::geometry) AS longitude,
    j.created_at,
    j.updated_at,
    jsonb_build_object(
      'id', cp.id,
      'full_name', cp.full_name,
      'avatar_url', cp.avatar_url
    ) AS customer,
    jsonb_build_object(
      'id', c.id,
      'name_en', c.name_en,
      'name_si', c.name_si,
      'name_ta', c.name_ta,
      'icon', c.icon
    ) AS category
  FROM jobs j
  LEFT JOIN profiles cp ON cp.id = j.customer_id
  LEFT JOIN categories c ON c.id = j.category_id
  WHERE j.category_id = ANY(p_category_ids)
    AND j.status::text IN ('broadcast', 'bidding')
  ORDER BY j.created_at DESC;
$$;
GRANT EXECUTE ON FUNCTION get_available_jobs_for_worker(uuid, uuid[])
  TO authenticated;

-- ── 4. Reviews for a worker, with public reviewer fields ────────
-- The reviews table uses reviewer_id / reviewee_id; the client model
-- expects them aliased as customer_id / worker_id (legacy naming),
-- so we surface them under those names here.
CREATE OR REPLACE FUNCTION get_worker_reviews_with_authors(
  p_worker_id uuid,
  p_limit int DEFAULT 20
)
RETURNS TABLE (
  id uuid,
  job_id uuid,
  customer_id uuid,
  worker_id uuid,
  rating int,
  comment text,
  created_at timestamptz,
  customer jsonb,
  job jsonb
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    r.id,
    r.job_id,
    r.reviewer_id AS customer_id,
    r.reviewee_id AS worker_id,
    r.rating,
    r.comment,
    r.created_at,
    jsonb_build_object(
      'full_name', rp.full_name,
      'avatar_url', rp.avatar_url
    ) AS customer,
    jsonb_build_object(
      'title', j.title,
      'category_id', j.category_id
    ) AS job
  FROM reviews r
  LEFT JOIN profiles rp ON rp.id = r.reviewer_id
  LEFT JOIN jobs j ON j.id = r.job_id
  WHERE r.reviewee_id = p_worker_id
  ORDER BY r.created_at DESC
  LIMIT p_limit;
$$;
GRANT EXECUTE ON FUNCTION get_worker_reviews_with_authors(uuid, int)
  TO authenticated;

COMMIT;

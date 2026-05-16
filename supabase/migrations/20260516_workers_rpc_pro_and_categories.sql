-- ═══════════════════════════════════════════════════════════════
-- Extend find_workers_for_customer to return Pro Pass status and
-- the worker's category list. The customer-home worker card needs
-- to show the Pro badge alongside the Verified badge, plus the
-- worker's skills row.
--
-- Notes:
--   * Need DROP FUNCTION first because CREATE OR REPLACE refuses to
--     change the return type (Postgres 42P13).
--   * `profiles.is_pro` doesn't exist as a column — Pro Pass status
--     is derived from the subscriptions table. A subscription is
--     "active" if status is 'active' OR 'cancelled' (benefits run
--     until the end of the current period in the cancelled state)
--     AND current_period_end is in the future. This matches the
--     semantic used by wallet_screen.dart for the ACTIVE/CANCELLING
--     badge.
-- ═══════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS find_workers_for_customer(
  double precision, double precision, uuid, boolean, int, int
);

CREATE FUNCTION find_workers_for_customer(
  p_lat double precision,
  p_lng double precision,
  p_category_id uuid DEFAULT NULL,
  p_online_only boolean DEFAULT false,
  p_radius_meters int DEFAULT 50000,  -- 50 km
  p_limit int DEFAULT 50
)
RETURNS TABLE (
  id uuid,
  full_name text,
  avatar_url text,
  tier text,
  average_rating numeric,
  jobs_completed_count int,
  verification_status text,
  is_online boolean,
  is_pro boolean,
  bio text,
  distance_m double precision,
  categories jsonb
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  WITH origin AS (
    SELECT ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography AS pt
  )
  SELECT
    p.id,
    p.full_name,
    p.avatar_url,
    p.tier::text,
    p.average_rating,
    p.jobs_completed_count,
    p.verification_status::text,
    p.is_online,
    EXISTS (
      SELECT 1 FROM subscriptions s
      WHERE s.user_id = p.id
        AND s.status IN ('active', 'cancelled')
        AND s.current_period_end > now()
    ) AS is_pro,
    p.bio,
    ST_Distance(p.location, (SELECT pt FROM origin)) AS distance_m,
    COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'id', c.id,
        'name_en', c.name_en,
        'name_si', c.name_si,
        'name_ta', c.name_ta
      ) ORDER BY c.name_en)
      FROM worker_categories wc
      JOIN categories c ON c.id = wc.category_id
      WHERE wc.worker_id = p.id
    ), '[]'::jsonb) AS categories
  FROM profiles p
  WHERE
    (p.role = 'worker' OR p.active_role = 'worker')
    AND p.location IS NOT NULL
    AND ST_DWithin(p.location, (SELECT pt FROM origin), p_radius_meters)
    AND (
      p_category_id IS NULL
      OR EXISTS (
        SELECT 1 FROM worker_categories wc
        WHERE wc.worker_id = p.id AND wc.category_id = p_category_id
      )
    )
    AND (p_online_only = false OR p.is_online = true)
  ORDER BY distance_m ASC
  LIMIT p_limit;
$$;

GRANT EXECUTE ON FUNCTION find_workers_for_customer(
  double precision, double precision, uuid, boolean, int, int
) TO authenticated, anon;

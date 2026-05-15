-- ═══════════════════════════════════════════════════════════════
-- Customer-facing nearest-worker discovery
--
-- Returns workers within optional radius of the customer location,
-- with their distance, optionally filtered by category and online
-- status. Mirrors the structure of find_nearby_workers but is meant
-- for browsing rather than job broadcast (no fcm_token, no hard
-- online/verified filters — those are user-controlled).
-- ═══════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION find_workers_for_customer(
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
  bio text,
  distance_m double precision
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
    p.bio,
    ST_Distance(p.location, (SELECT pt FROM origin)) AS distance_m
  FROM profiles p
  WHERE
    -- Worker accounts (current or signup role)
    (p.role = 'worker' OR p.active_role = 'worker')
    -- Must have a location to be distance-sortable
    AND p.location IS NOT NULL
    -- Radius gate (PostGIS uses meters on geography)
    AND ST_DWithin(p.location, (SELECT pt FROM origin), p_radius_meters)
    -- Optional category filter via worker_categories
    AND (
      p_category_id IS NULL
      OR EXISTS (
        SELECT 1 FROM worker_categories wc
        WHERE wc.worker_id = p.id AND wc.category_id = p_category_id
      )
    )
    -- Optional online filter
    AND (p_online_only = false OR p.is_online = true)
  ORDER BY distance_m ASC
  LIMIT p_limit;
$$;

-- Allow authenticated users to call the RPC (RLS on profiles still
-- applies to anything the function returns to the caller via
-- PostgREST, but SECURITY DEFINER lets the function read profiles
-- regardless of the tightened RLS we plan to add).
GRANT EXECUTE ON FUNCTION find_workers_for_customer(
  double precision, double precision, uuid, boolean, int, int
) TO authenticated, anon;

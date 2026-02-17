-- ═══════════════════════════════════════════════════════════════
-- PostGIS helper: find nearby workers for job broadcast
-- ═══════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION find_nearby_workers(
  p_job_location geography,
  p_category_id uuid,
  p_radius_meters int DEFAULT 5000,
  p_limit int DEFAULT 10
)
RETURNS TABLE (
  id uuid,
  full_name text,
  fcm_token text,
  distance_m double precision,
  has_subscription boolean
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT
    p.id,
    p.full_name,
    p.fcm_token,
    ST_Distance(p.location, p_job_location) AS distance_m,
    EXISTS (
      SELECT 1 FROM subscriptions s
      WHERE s.user_id = p.id AND s.status = 'active'
    ) AS has_subscription
  FROM profiles p
  INNER JOIN worker_categories wc ON wc.worker_id = p.id
  WHERE p.role = 'worker'
    AND p.is_online = true
    AND p.verification_status = 'verified'
    AND wc.category_id = p_category_id
    AND ST_DWithin(p.location, p_job_location, p_radius_meters)
  ORDER BY
    has_subscription DESC,  -- Pro Pass subscribers first
    distance_m ASC          -- Then by distance
  LIMIT p_limit;
$$;

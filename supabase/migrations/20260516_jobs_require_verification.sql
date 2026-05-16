-- Tighten the jobs INSERT policy so only ID-verified customers can post jobs.
-- The original policy from 00004 only enforced ownership (auth.uid() = customer_id).
-- We now also require the inserting user's profile to be in verification_status='verified'.
-- service_role bypasses RLS, so admin/automated paths keep working.

DROP POLICY IF EXISTS "Jobs: customer can insert own" ON jobs;

CREATE POLICY "Jobs: verified customer can insert own"
  ON jobs FOR INSERT
  WITH CHECK (
    auth.uid() = customer_id
    AND EXISTS (
      SELECT 1
      FROM profiles
      WHERE id = auth.uid()
        AND verification_status = 'verified'
    )
  );

-- ═══════════════════════════════════════════════════════════════
-- Tighten the counterparty profile-read policy so phone (and any
-- other field on `profiles`) is only readable by the other party
-- AFTER both sides have agreed on a job (status = matched / etc.).
--
-- The original policy granted counterparty access on EITHER:
--   (a) a matched job between the two parties, OR
--   (b) any conversation between them.
--
-- (b) is the leak — a customer or worker could start a chat and
-- immediately read the other party's phone before either side has
-- committed to a job. The product expectation is: phone stays
-- hidden until a job has been created and accepted by both sides.
-- A `matched` job already implies "both parties approved" because
-- the customer has to accept the worker's bid to flip the status.
-- ═══════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Profiles: counterparty can read" ON profiles;

CREATE POLICY "Profiles: counterparty can read"
  ON profiles FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM jobs j
      WHERE
        j.status IN ('matched', 'in_progress', 'completed', 'disputed')
        AND (
          (j.customer_id = auth.uid() AND j.matched_worker_id = profiles.id)
          OR (j.matched_worker_id = auth.uid() AND j.customer_id = profiles.id)
        )
    )
  );

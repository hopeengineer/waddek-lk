-- RPC the worker calls from inside the chat to accept a job proposal.
-- Atomically flips the job's status to 'matched' and binds the
-- conversation to it. Uses SECURITY DEFINER so the worker can update
-- a job they don't yet "own" — the guard inside the function checks
-- they're the matched_worker_id on a draft job.
CREATE OR REPLACE FUNCTION accept_chat_proposed_job(
  p_job_id uuid,
  p_conversation_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM jobs
    WHERE id = p_job_id
      AND matched_worker_id = auth.uid()
      AND status = 'draft'
  ) THEN
    RAISE EXCEPTION 'Not authorised to accept this job';
  END IF;

  UPDATE jobs SET status = 'matched' WHERE id = p_job_id;

  UPDATE conversations
  SET job_id = p_job_id
  WHERE id = p_conversation_id
    AND (worker_id = auth.uid() OR customer_id = auth.uid());
END;
$$;

GRANT EXECUTE ON FUNCTION accept_chat_proposed_job(uuid, uuid) TO authenticated;

-- ═══════════════════════════════════════════════════════════════
-- Allow conversations to exist before a job is created.
--
-- New flow: customer taps "Message" on a worker's profile →
-- creates a conversation with NO job_id → opens the chat → optionally
-- proposes a job from inside the chat (which sets job_id and creates
-- the Job in `draft` state). Worker accepts → job transitions to
-- `matched`. This lets two parties chat without committing to a job
-- and without spamming the jobs table with throwaway records.
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE conversations ALTER COLUMN job_id DROP NOT NULL;

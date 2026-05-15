-- ═══════════════════════════════════════════════════════════════
-- Chat schema gaps: columns the client was already writing that
-- the original migrations never created.
--
-- The Flutter client was:
--   * ordering conversations by `last_message_at` and writing it
--     back when sending a message (chat_repository.dart:25,96)
--   * inserting a `type` column on messages
--     (chat_repository.dart:88)
-- Neither column exists in 00002_create_tables.sql, so the
-- /conversations route threw PostgrestException 42703 (column does
-- not exist).
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ── conversations.last_message_at ────────────────────────────────
ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS last_message_at timestamptz;

-- Backfill with the most recent message timestamp per conversation,
-- falling back to the conversation's own created_at so existing rows
-- have a sensible sort key.
UPDATE conversations c
SET last_message_at = COALESCE(
  (SELECT MAX(m.created_at) FROM messages m WHERE m.conversation_id = c.id),
  c.created_at
)
WHERE c.last_message_at IS NULL;

-- Keep it current automatically so the client doesn't have to
-- write it on every send.
CREATE OR REPLACE FUNCTION bump_conversation_last_message_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE conversations
    SET last_message_at = NEW.created_at
    WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_messages_bump_conversation ON messages;
CREATE TRIGGER trg_messages_bump_conversation
AFTER INSERT ON messages
FOR EACH ROW EXECUTE FUNCTION bump_conversation_last_message_at();

-- ── messages.type ────────────────────────────────────────────────
-- 'text' covers the only kind the app sends today; image/system
-- messages can use the same column later.
ALTER TABLE messages
  ADD COLUMN IF NOT EXISTS type text NOT NULL DEFAULT 'text';

COMMIT;

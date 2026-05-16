-- ═══════════════════════════════════════════════════════════════
-- Editable phone / email with re-verification.
--
-- Rule: the live phone/email on profiles & auth.users only changes
-- AFTER the new value is verified. Any failure leaves the old value
-- intact.
--
-- Strategy:
--   * Phone — custom OTP flow (Notify.lk). Server stages the new
--     phone in profiles.pending_phone, sends OTP to it. On verify,
--     atomically swap into auth.users.phone + profiles.phone and
--     clear pending_phone. Any error → pending_phone may stay set
--     for retry, but live phone is untouched.
--
--   * Email — Supabase's built-in auth.updateUser({email}) handles
--     the confirmation flow natively (sends a magic link to the new
--     address, only commits auth.users.email after the user clicks).
--     We stage profiles.pending_email for UI display only. A trigger
--     on auth.users mirrors the eventual email change into
--     profiles.email and clears pending_email.
-- ═══════════════════════════════════════════════════════════════

BEGIN;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS pending_phone text,
  ADD COLUMN IF NOT EXISTS pending_email text;

-- Mirror auth.users.email -> profiles.email whenever Supabase's
-- built-in email-change flow commits a confirmed new email.
CREATE OR REPLACE FUNCTION fn_sync_email_from_auth()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.email IS DISTINCT FROM OLD.email THEN
    UPDATE profiles
      SET email = NEW.email,
          pending_email = NULL
      WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_auth_user_sync_email ON auth.users;
CREATE TRIGGER trg_auth_user_sync_email
  AFTER UPDATE OF email ON auth.users
  FOR EACH ROW EXECUTE FUNCTION fn_sync_email_from_auth();

COMMIT;

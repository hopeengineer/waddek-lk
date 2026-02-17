-- ═══════════════════════════════════════════════════════════════
-- Waddek.lk — Triggers
-- ═══════════════════════════════════════════════════════════════

-- ── Auto-update updated_at timestamps ─────────────────────────
CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);

CREATE TRIGGER trg_jobs_updated_at
  BEFORE UPDATE ON jobs
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);

CREATE TRIGGER trg_bids_updated_at
  BEFORE UPDATE ON bids
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);

CREATE TRIGGER trg_wallets_updated_at
  BEFORE UPDATE ON wallets
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);

CREATE TRIGGER trg_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);

CREATE TRIGGER trg_disputes_updated_at
  BEFORE UPDATE ON disputes
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);

-- ── Auto-create wallet on profile insert ──────────────────────
CREATE OR REPLACE FUNCTION fn_create_wallet()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO wallets (user_id) VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_profile_create_wallet
  AFTER INSERT ON profiles
  FOR EACH ROW EXECUTE FUNCTION fn_create_wallet();

-- ── Update average_rating and jobs_completed on review insert ─
CREATE OR REPLACE FUNCTION fn_review_inserted()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE profiles
  SET
    average_rating = (
      SELECT ROUND(AVG(rating)::numeric, 1)
      FROM reviews
      WHERE reviewee_id = NEW.reviewee_id
    ),
    jobs_completed_count = (
      SELECT COUNT(DISTINCT job_id)
      FROM reviews
      WHERE reviewee_id = NEW.reviewee_id
    )
  WHERE id = NEW.reviewee_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_review_inserted
  AFTER INSERT ON reviews
  FOR EACH ROW EXECUTE FUNCTION fn_review_inserted();

-- ── Cleanup expired OTP codes (called periodically) ──────────
CREATE OR REPLACE FUNCTION fn_cleanup_expired_otps()
RETURNS void AS $$
BEGIN
  DELETE FROM otp_codes
  WHERE expires_at < now() OR used = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

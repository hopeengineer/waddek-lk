-- ═══════════════════════════════════════════════════════════════
-- Waddek.lk — Row Level Security Policies
-- ═══════════════════════════════════════════════════════════════

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE worker_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE bids ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE top_up_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE otp_codes ENABLE ROW LEVEL SECURITY;

-- ── Profiles ──────────────────────────────────────────────────
CREATE POLICY "Profiles: viewable by everyone"
  ON profiles FOR SELECT USING (true);
CREATE POLICY "Profiles: user can update own"
  ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Profiles: user can insert own"
  ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- ── Categories (public read) ─────────────────────────────────
CREATE POLICY "Categories: public read"
  ON categories FOR SELECT USING (true);

-- ── Worker Categories ────────────────────────────────────────
CREATE POLICY "Worker categories: public read"
  ON worker_categories FOR SELECT USING (true);
CREATE POLICY "Worker categories: worker can manage own"
  ON worker_categories FOR ALL USING (auth.uid() = worker_id);

-- ── Portfolio Images ─────────────────────────────────────────
CREATE POLICY "Portfolio: public read"
  ON portfolio_images FOR SELECT USING (true);
CREATE POLICY "Portfolio: worker can manage own"
  ON portfolio_images FOR ALL USING (auth.uid() = worker_id);

-- ── Jobs ──────────────────────────────────────────────────────
CREATE POLICY "Jobs: viewable by everyone"
  ON jobs FOR SELECT USING (true);
CREATE POLICY "Jobs: customer can insert own"
  ON jobs FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "Jobs: customer can update own"
  ON jobs FOR UPDATE USING (auth.uid() = customer_id);

-- ── Bids ──────────────────────────────────────────────────────
CREATE POLICY "Bids: parties can view"
  ON bids FOR SELECT USING (
    auth.uid() = worker_id OR
    auth.uid() IN (SELECT customer_id FROM jobs WHERE jobs.id = bids.job_id)
  );
CREATE POLICY "Bids: worker can insert own"
  ON bids FOR INSERT WITH CHECK (auth.uid() = worker_id);
CREATE POLICY "Bids: worker can update own"
  ON bids FOR UPDATE USING (auth.uid() = worker_id);

-- ── Wallets (private) ────────────────────────────────────────
CREATE POLICY "Wallets: user can view own"
  ON wallets FOR SELECT USING (auth.uid() = user_id);
-- Inserts/updates by Edge Functions only (service_role)

-- ── Transactions (private) ───────────────────────────────────
CREATE POLICY "Transactions: user can view own"
  ON transactions FOR SELECT USING (
    wallet_id IN (SELECT id FROM wallets WHERE user_id = auth.uid())
  );

-- ── Top-Up Packages (public read) ───────────────────────────
CREATE POLICY "Top-up packages: public read"
  ON top_up_packages FOR SELECT USING (is_active = true);

-- ── Subscription Plans (public read) ────────────────────────
CREATE POLICY "Subscription plans: public read"
  ON subscription_plans FOR SELECT USING (is_active = true);

-- ── Subscriptions (private) ─────────────────────────────────
CREATE POLICY "Subscriptions: user can view own"
  ON subscriptions FOR SELECT USING (auth.uid() = user_id);

-- ── Reviews ───────────────────────────────────────────────────
CREATE POLICY "Reviews: public read"
  ON reviews FOR SELECT USING (true);
CREATE POLICY "Reviews: reviewer can insert"
  ON reviews FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- ── Notifications (private) ──────────────────────────────────
CREATE POLICY "Notifications: user can view own"
  ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Notifications: user can update own (mark read)"
  ON notifications FOR UPDATE USING (auth.uid() = user_id);

-- ── Conversations ────────────────────────────────────────────
CREATE POLICY "Conversations: parties can view"
  ON conversations FOR SELECT USING (
    auth.uid() = customer_id OR auth.uid() = worker_id
  );

-- ── Messages ─────────────────────────────────────────────────
CREATE POLICY "Messages: parties can view"
  ON messages FOR SELECT USING (
    conversation_id IN (
      SELECT id FROM conversations
      WHERE customer_id = auth.uid() OR worker_id = auth.uid()
    )
  );
CREATE POLICY "Messages: sender can insert"
  ON messages FOR INSERT WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "Messages: recipient can mark read"
  ON messages FOR UPDATE USING (
    conversation_id IN (
      SELECT id FROM conversations
      WHERE customer_id = auth.uid() OR worker_id = auth.uid()
    )
  );

-- ── Disputes ─────────────────────────────────────────────────
CREATE POLICY "Disputes: parties can view"
  ON disputes FOR SELECT USING (
    auth.uid() = raised_by OR
    auth.uid() IN (SELECT customer_id FROM jobs WHERE jobs.id = disputes.job_id) OR
    auth.uid() IN (SELECT matched_worker_id FROM jobs WHERE jobs.id = disputes.job_id)
  );
CREATE POLICY "Disputes: user can insert"
  ON disputes FOR INSERT WITH CHECK (auth.uid() = raised_by);

-- ── OTP Codes (service_role only) ────────────────────────────
-- No user-facing RLS policies: managed entirely by Edge Functions via service_role

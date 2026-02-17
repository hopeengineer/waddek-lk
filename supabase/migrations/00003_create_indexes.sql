-- ═══════════════════════════════════════════════════════════════
-- Waddek.lk — Indexes
-- ═══════════════════════════════════════════════════════════════

-- Spatial indexes (PostGIS GIST)
CREATE INDEX idx_profiles_location ON profiles USING GIST (location);
CREATE INDEX idx_jobs_location ON jobs USING GIST (location);

-- Profile lookups
CREATE INDEX idx_profiles_role ON profiles (role);
CREATE INDEX idx_profiles_tier ON profiles (tier);
CREATE INDEX idx_profiles_verification ON profiles (verification_status);
CREATE INDEX idx_profiles_online ON profiles (is_online) WHERE is_online = true;

-- Job lookups
CREATE INDEX idx_jobs_status ON jobs (status);
CREATE INDEX idx_jobs_customer ON jobs (customer_id);
CREATE INDEX idx_jobs_category ON jobs (category_id);
CREATE INDEX idx_jobs_category_status ON jobs (category_id, status);
CREATE INDEX idx_jobs_created ON jobs (created_at DESC);

-- Bid lookups
CREATE INDEX idx_bids_job ON bids (job_id);
CREATE INDEX idx_bids_worker ON bids (worker_id);
CREATE INDEX idx_bids_status ON bids (job_id, status);

-- Wallet
CREATE INDEX idx_wallets_user ON wallets (user_id);

-- Transactions
CREATE INDEX idx_transactions_wallet ON transactions (wallet_id);
CREATE INDEX idx_transactions_type ON transactions (wallet_id, type);
CREATE INDEX idx_transactions_created ON transactions (wallet_id, created_at DESC);
CREATE UNIQUE INDEX idx_transactions_idempotency ON transactions (idempotency_key) WHERE idempotency_key IS NOT NULL;

-- Subscriptions
CREATE INDEX idx_subscriptions_user ON subscriptions (user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions (user_id, status);

-- Reviews
CREATE INDEX idx_reviews_reviewee ON reviews (reviewee_id);
CREATE INDEX idx_reviews_job ON reviews (job_id);

-- Notifications
CREATE INDEX idx_notifications_user ON notifications (user_id, is_read, created_at DESC);

-- Conversations & Messages
CREATE INDEX idx_conversations_customer ON conversations (customer_id);
CREATE INDEX idx_conversations_worker ON conversations (worker_id);
CREATE INDEX idx_messages_conversation ON messages (conversation_id, created_at);
CREATE INDEX idx_messages_unread ON messages (conversation_id, is_read) WHERE is_read = false;

-- Disputes
CREATE INDEX idx_disputes_job ON disputes (job_id);
CREATE INDEX idx_disputes_status ON disputes (status);

-- OTP
CREATE INDEX idx_otp_phone ON otp_codes (phone, expires_at);

-- Text search (trigram)
CREATE INDEX idx_jobs_title_trgm ON jobs USING GIN (title gin_trgm_ops);

-- Worker categories
CREATE INDEX idx_worker_categories_worker ON worker_categories (worker_id);
CREATE INDEX idx_worker_categories_category ON worker_categories (category_id);

-- ═══════════════════════════════════════════════════════════════
-- Waddek.lk — Table Definitions
-- ═══════════════════════════════════════════════════════════════

-- ── Enums ─────────────────────────────────────────────────────
CREATE TYPE user_role AS ENUM ('customer', 'worker', 'admin');
CREATE TYPE tier_level AS ENUM ('waddek', 'professional', 'supiri');
CREATE TYPE job_status AS ENUM (
  'draft', 'broadcast', 'bidding', 'matched',
  'in_progress', 'completed', 'cancelled', 'disputed'
);
CREATE TYPE bid_status AS ENUM ('pending', 'accepted', 'rejected', 'expired');
CREATE TYPE transaction_type AS ENUM ('top_up', 'lead_fee', 'refund', 'bonus', 'withdrawal', 'subscription');
CREATE TYPE verification_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');
CREATE TYPE dispute_status AS ENUM ('open', 'under_review', 'resolved_customer', 'resolved_worker', 'closed');
CREATE TYPE subscription_status AS ENUM ('active', 'past_due', 'cancelled', 'expired');

-- ── Profiles ──────────────────────────────────────────────────
CREATE TABLE profiles (
  id              uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone           text NOT NULL,
  email           text,
  full_name       text,
  avatar_url      text,
  role            user_role NOT NULL DEFAULT 'customer',
  tier            tier_level NOT NULL DEFAULT 'waddek',
  bio             text,
  location        geography(Point, 4326),    -- PostGIS point
  is_online       boolean DEFAULT false,
  average_rating  numeric(2,1) DEFAULT 0,
  jobs_completed_count int DEFAULT 0,
  verification_status verification_status DEFAULT 'unverified',
  nic_front_url   text,
  nic_back_url    text,
  nic_number      text,
  fcm_token       text,
  preferred_locale text DEFAULT 'en',        -- 'en', 'si', 'ta'
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);

-- ── Categories ────────────────────────────────────────────────
CREATE TABLE categories (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name_en     text NOT NULL,
  name_si     text NOT NULL,
  name_ta     text NOT NULL,
  icon        text,                          -- icon identifier
  sort_order  int DEFAULT 0,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now()
);

-- ── Worker → Category (M:N) ──────────────────────────────────
CREATE TABLE worker_categories (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  worker_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category_id uuid NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  experience_years int DEFAULT 0,
  created_at  timestamptz DEFAULT now(),
  UNIQUE(worker_id, category_id)
);

-- ── Portfolio Images ──────────────────────────────────────────
CREATE TABLE portfolio_images (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  worker_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  image_url   text NOT NULL,
  caption     text,
  sort_order  int DEFAULT 0,
  created_at  timestamptz DEFAULT now()
);

-- ── Jobs ──────────────────────────────────────────────────────
CREATE TABLE jobs (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category_id     uuid NOT NULL REFERENCES categories(id),
  title           text NOT NULL,
  description     text,
  location        geography(Point, 4326) NOT NULL,
  address         text,
  budget_min      numeric(10,2),
  budget_max      numeric(10,2),
  status          job_status NOT NULL DEFAULT 'draft',
  matched_worker_id uuid REFERENCES profiles(id),
  scheduled_at    timestamptz,
  photo_urls      text[],
  broadcast_radius_km int DEFAULT 5,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);

-- ── Bids ──────────────────────────────────────────────────────
CREATE TABLE bids (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id      uuid NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  worker_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  amount      numeric(10,2) NOT NULL,
  message     text,
  status      bid_status NOT NULL DEFAULT 'pending',
  is_unlocked boolean DEFAULT false,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now(),
  UNIQUE(job_id, worker_id)
);

-- ── Wallets ───────────────────────────────────────────────────
CREATE TABLE wallets (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  balance     numeric(10,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- ── Transactions ──────────────────────────────────────────────
CREATE TABLE transactions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id       uuid NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
  type            transaction_type NOT NULL,
  amount          numeric(10,2) NOT NULL,
  balance_after   numeric(10,2) NOT NULL,
  description     text,
  reference_id    text,               -- PayHere order ID, job ID, subscription ID, etc.
  idempotency_key text UNIQUE,        -- prevents double-charges
  created_at      timestamptz DEFAULT now()
);

-- ── Top-Up Packages ──────────────────────────────────────────
CREATE TABLE top_up_packages (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  amount      numeric(10,2) NOT NULL,           -- e.g. 200
  bonus       numeric(10,2) NOT NULL DEFAULT 0, -- e.g. 25
  label_en    text NOT NULL,
  label_si    text,
  label_ta    text,
  sort_order  int DEFAULT 0,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now()
);

-- ── Subscription Plans ───────────────────────────────────────
CREATE TABLE subscription_plans (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name            text NOT NULL,                    -- 'Waddek Pro Pass'
  price           numeric(10,2) NOT NULL,           -- 1500.00
  period_months   int NOT NULL DEFAULT 1,
  unlock_cap      int NOT NULL DEFAULT 50,          -- fair-use cap per month
  is_active       boolean DEFAULT true,
  created_at      timestamptz DEFAULT now()
);

-- ── Subscriptions ────────────────────────────────────────────
CREATE TABLE subscriptions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  plan_id         uuid NOT NULL REFERENCES subscription_plans(id),
  status          subscription_status NOT NULL DEFAULT 'active',
  payhere_subscription_id text,                     -- PayHere recurring ID
  current_period_start timestamptz NOT NULL DEFAULT now(),
  current_period_end   timestamptz NOT NULL,
  unlocks_this_period  int DEFAULT 0,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);

-- ── Reviews ───────────────────────────────────────────────────
CREATE TABLE reviews (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id      uuid NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  reviewer_id uuid NOT NULL REFERENCES profiles(id),
  reviewee_id uuid NOT NULL REFERENCES profiles(id),
  rating      int NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment     text,
  created_at  timestamptz DEFAULT now(),
  UNIQUE(job_id, reviewer_id)               -- one review per job per reviewer
);

-- ── Notifications ─────────────────────────────────────────────
CREATE TABLE notifications (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type        text NOT NULL,
  title       text NOT NULL,
  body        text,
  data        jsonb,                         -- reference IDs, deep-link info
  is_read     boolean DEFAULT false,
  created_at  timestamptz DEFAULT now()
);

-- ── Conversations ─────────────────────────────────────────────
CREATE TABLE conversations (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id      uuid NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  customer_id uuid NOT NULL REFERENCES profiles(id),
  worker_id   uuid NOT NULL REFERENCES profiles(id),
  created_at  timestamptz DEFAULT now(),
  UNIQUE(job_id)
);

-- ── Messages ──────────────────────────────────────────────────
CREATE TABLE messages (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id       uuid NOT NULL REFERENCES profiles(id),
  content         text NOT NULL,
  is_read         boolean DEFAULT false,
  created_at      timestamptz DEFAULT now()
);

-- ── Disputes ──────────────────────────────────────────────────
CREATE TABLE disputes (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id      uuid NOT NULL REFERENCES jobs(id),
  raised_by   uuid NOT NULL REFERENCES profiles(id),
  reason      text NOT NULL,
  evidence_urls text[],
  status      dispute_status NOT NULL DEFAULT 'open',
  admin_notes text,
  resolved_at timestamptz,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- ── OTP Codes (for Notify.lk custom OTP) ─────────────────────
CREATE TABLE otp_codes (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone       text NOT NULL,
  code_hash   text NOT NULL,
  attempts    int DEFAULT 0,
  expires_at  timestamptz NOT NULL,
  used        boolean DEFAULT false,
  created_at  timestamptz DEFAULT now()
);

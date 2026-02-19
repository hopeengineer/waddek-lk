-- Migration: Add active_role and registration_completed to profiles table
-- Supports dual accounts (customer + worker) and the new registration flow

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS active_role text DEFAULT 'customer',
  ADD COLUMN IF NOT EXISTS registration_completed boolean DEFAULT false;

-- Migrate existing users: set active_role from their current role
UPDATE profiles SET active_role = role WHERE active_role IS NULL OR active_role = 'customer';

-- Mark existing users as registration_completed (they already went through old flow)
UPDATE profiles SET registration_completed = true WHERE registration_completed = false AND role IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════
-- Create storage buckets + RLS policies.
--
-- These were referenced by the Flutter app (avatars, nic-photos,
-- portfolio, job-photos, evidence per
-- lib/core/constants/supabase_constants.dart:25-29) but were never
-- created in storage.buckets, so every upload failed with
-- "Bucket not found, statusCode: 404".
--
-- Public-readable buckets: avatars, portfolio, job-photos
--   These are displayed across the app to other users, and the
--   avatars bucket specifically must be public so Shufti Pro can
--   fetch the URL during face-match (face.proof parameter).
--
-- Private buckets: nic-photos, evidence
--   These contain PII / dispute evidence. Only the owner and
--   server-side service_role can read.
--
-- Folder convention: every upload path starts with <user_id>/...
-- (see StorageService.uploadAvatar at
-- lib/core/services/storage_service.dart:44-50). RLS policies use
-- `(storage.foldername(name))[1] = auth.uid()::text` to enforce
-- per-user write isolation.
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ── Buckets ──────────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('avatars',     'avatars',     true,  5242880,  ARRAY['image/jpeg','image/png','image/webp']),
  ('portfolio',   'portfolio',   true,  10485760, ARRAY['image/jpeg','image/png','image/webp']),
  ('job-photos',  'job-photos',  true,  10485760, ARRAY['image/jpeg','image/png','image/webp']),
  ('nic-photos',  'nic-photos',  false, 10485760, ARRAY['image/jpeg','image/png','image/webp']),
  ('evidence',    'evidence',    false, 26214400, ARRAY['image/jpeg','image/png','image/webp','application/pdf'])
ON CONFLICT (id) DO NOTHING;

-- ── RLS policies on storage.objects ──────────────────────────
-- INSERT / UPDATE / DELETE: authenticated user can manage files
-- in their own folder (the first path segment must equal auth.uid).

CREATE POLICY "avatars: owner can insert"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "avatars: owner can update"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "avatars: owner can delete"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "portfolio: owner can insert"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'portfolio'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "portfolio: owner can update"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'portfolio'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "portfolio: owner can delete"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'portfolio'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "job-photos: owner can insert"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'job-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "job-photos: owner can update"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'job-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "job-photos: owner can delete"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'job-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Private buckets: NIC and evidence. Owner can read + write.
CREATE POLICY "nic-photos: owner full access"
  ON storage.objects FOR ALL TO authenticated
  USING (
    bucket_id = 'nic-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'nic-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "evidence: owner full access"
  ON storage.objects FOR ALL TO authenticated
  USING (
    bucket_id = 'evidence'
    AND (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'evidence'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

COMMIT;

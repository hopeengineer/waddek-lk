import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_constants.dart';

/// Storage helper for uploading/downloading files from Supabase Storage.
abstract class StorageService {
  static SupabaseStorageClient get _storage =>
      Supabase.instance.client.storage;

  /// Upload a file and return its public URL.
  ///
  /// [bucket] — The storage bucket name (e.g. 'avatars', 'nic-photos').
  /// [path]   — The path within the bucket (e.g. 'user_id/avatar.jpg').
  /// [bytes]  — The file bytes.
  static Future<String> upload({
    required String bucket,
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async {
    await _storage.from(bucket).uploadBinary(
      path,
      bytes as dynamic,
      fileOptions: FileOptions(
        contentType: contentType ?? 'image/jpeg',
        upsert: true,
      ),
    );
    return _storage.from(bucket).getPublicUrl(path);
  }

  /// Get the public URL for an existing file.
  static String getPublicUrl(String bucket, String path) {
    return _storage.from(bucket).getPublicUrl(path);
  }

  /// Delete a file from storage.
  static Future<void> delete(String bucket, String path) async {
    await _storage.from(bucket).remove([path]);
  }

  // ── Convenience methods for specific buckets ────────────

  static Future<String> uploadAvatar(String userId, List<int> bytes) {
    return upload(
      bucket: SupabaseConstants.avatarsBucket,
      path: '$userId/avatar.jpg',
      bytes: bytes,
    );
  }

  static Future<String> uploadNicPhoto(String userId, String side, List<int> bytes) {
    return upload(
      bucket: SupabaseConstants.nicPhotosBucket,
      path: '$userId/nic_$side.jpg',
      bytes: bytes,
    );
  }

  static Future<String> uploadPortfolioImage(String userId, String imageId, List<int> bytes) {
    return upload(
      bucket: SupabaseConstants.portfolioBucket,
      path: '$userId/$imageId.jpg',
      bytes: bytes,
    );
  }

  static Future<String> uploadJobPhoto(String jobId, String photoId, List<int> bytes) {
    return upload(
      bucket: SupabaseConstants.jobPhotosBucket,
      path: '$jobId/$photoId.jpg',
      bytes: bytes,
    );
  }
}

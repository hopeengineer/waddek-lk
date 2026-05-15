import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import '../providers/profile_provider.dart';

/// Edit screen for both worker and customer profile basic info.
/// (Skills and portfolio live on their own dedicated screens.)
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.neonCyan),
                  )
                : const Text('Save',
                    style: TextStyle(
                        color: AppColors.neonCyan,
                        fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile loaded'));
          }
          if (!_initialized) {
            _nameCtrl.text = profile.fullName ?? '';
            _emailCtrl.text = profile.email ?? '';
            _bioCtrl.text = profile.bio ?? '';
            _initialized = true;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.bgSurface,
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? const Icon(Icons.person,
                              size: 50, color: AppColors.neonCyan)
                          : null,
                    ),
                    Material(
                      color: AppColors.neonCyan,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _pickAvatar,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.camera_alt,
                              size: 16, color: AppColors.bgDark),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon:
                        Icon(Icons.person, color: AppColors.neonCyan),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon:
                        Icon(Icons.email, color: AppColors.neonCyan),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'About you',
                    hintText:
                        'Tell customers what you do and what makes you different.',
                    prefixIcon:
                        Icon(Icons.description, color: AppColors.neonCyan),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Phone: ${profile.phone}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                NeonButton(
                  label: 'Save changes',
                  icon: Icons.check,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.bgSurface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_camera, color: AppColors.neonCyan),
              title: const Text('Take photo',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.neonCyan),
              title: const Text('Choose from gallery',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;

    try {
      await ref
          .read(currentProfileProvider.notifier)
          .uploadAvatar(picked.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar upload failed: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final fields = <String, dynamic>{
        'full_name':
            _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        'email':
            _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      };
      await ref.read(currentProfileProvider.notifier).updateProfile(fields);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated.'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

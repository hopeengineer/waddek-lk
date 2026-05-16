import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/utils/validators.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// Edit screen for both worker and customer profile basic info.
/// (Skills and portfolio live on their own dedicated screens.)
///
/// Phone and email changes are NOT applied directly to the live
/// columns. Phone goes through the change_phone OTP flow; email
/// goes through Supabase's built-in email-change confirmation. The
/// old value stays in place until the new one is verified.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _saving = false;
  bool _initialized = false;
  String _originalPhone = '';
  String? _originalEmail;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
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
            _phoneCtrl.text = profile.phone;
            _bioCtrl.text = profile.bio ?? '';
            _originalPhone = profile.phone;
            _originalEmail = profile.email;
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
                  enabled: !profile.identityLocked,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Full name',
                    prefixIcon:
                        const Icon(Icons.person, color: AppColors.neonCyan),
                    helperText: profile.identityLocked
                        ? 'Locked from your verified ID.'
                        : null,
                    helperStyle: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                    suffixIcon: profile.identityLocked
                        ? const Icon(Icons.lock,
                            color: AppColors.neonGreen, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                if (profile.identityLocked) ...[
                  _ReadOnlyTile(
                    icon: Icons.cake,
                    label: 'Age',
                    value: profile.age != null
                        ? '${profile.age}'
                        : 'Unknown',
                  ),
                  if (profile.gender != null && profile.gender!.isNotEmpty)
                    _ReadOnlyTile(
                      icon: Icons.person_outline,
                      label: 'Gender',
                      value: profile.gender!,
                    ),
                  if (profile.nationality != null &&
                      profile.nationality!.isNotEmpty)
                    _ReadOnlyTile(
                      icon: Icons.public,
                      label: 'Nationality',
                      value: profile.nationality!,
                    ),
                ],
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon:
                        const Icon(Icons.phone, color: AppColors.neonCyan),
                    helperText: profile.pendingPhone != null
                        ? 'Pending verification: ${profile.pendingPhone}'
                        : 'Changing this will send an OTP to the new number.',
                    helperStyle: TextStyle(
                      color: profile.pendingPhone != null
                          ? AppColors.neonAmber
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                        const Icon(Icons.email, color: AppColors.neonCyan),
                    helperText: profile.pendingEmail != null
                        ? 'Pending verification: ${profile.pendingEmail}'
                        : 'Changing this will send a confirmation link to the new address.',
                    helperStyle: TextStyle(
                      color: profile.pendingEmail != null
                          ? AppColors.neonAmber
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
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
      // 1. Persist the fields that don't need verification.
      //    full_name is excluded when identity is locked — the
      //    BEFORE UPDATE trigger on profiles would reject it anyway.
      final profile =
          ref.read(currentProfileProvider).valueOrNull;
      final fields = <String, dynamic>{
        if (profile == null || !profile.identityLocked)
          'full_name': _nameCtrl.text.trim().isEmpty
              ? null
              : _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      };
      await ref.read(currentProfileProvider.notifier).updateProfile(fields);

      // 2. If email changed, hand off to Supabase's confirmation flow.
      //    The live email won't move until the user clicks the link.
      final newEmail = _emailCtrl.text.trim();
      if (newEmail.isNotEmpty && newEmail != (_originalEmail ?? '')) {
        await ref
            .read(authRepositoryProvider)
            .requestEmailChange(newEmail);
        await ref.read(currentProfileProvider.notifier).loadProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Confirmation link sent to the new email address.'),
              backgroundColor: AppColors.neonGreen,
            ),
          );
        }
      }

      // 3. If phone changed, stage it and route to OTP verification.
      //    The live phone won't move until verifyPhoneChange succeeds.
      final newPhone = _phoneCtrl.text.trim();
      if (newPhone.isNotEmpty) {
        final normalized = Validators.normalizePhone(newPhone);
        if (normalized != _originalPhone) {
          final ok = await ref
              .read(authProvider.notifier)
              .sendPhoneChangeOtp(normalized);
          if (ok && mounted) {
            await context.pushNamed(
              'otp-verify-phone-change',
              extra: normalized,
            );
            await ref.read(currentProfileProvider.notifier).loadProfile();
          } else if (mounted) {
            final err = ref.read(authProvider).errorMessage ??
                'Could not send code.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(err),
                backgroundColor: AppColors.neonRed,
              ),
            );
            return; // keep the user on this screen so they can retry
          }
        }
      }

      if (mounted && newPhone.isNotEmpty &&
          Validators.normalizePhone(newPhone) == _originalPhone &&
          (newEmail.isEmpty || newEmail == (_originalEmail ?? ''))) {
        // Nothing needed verification → simple save path.
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

class _ReadOnlyTile extends StatelessWidget {
  const _ReadOnlyTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonCyan, size: 20),
          const SizedBox(width: 12),
          Text('$label:',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500)),
          ),
          const Icon(Icons.lock, color: AppColors.neonGreen, size: 16),
        ],
      ),
    );
  }
}

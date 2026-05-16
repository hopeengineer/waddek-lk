import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/trust_badges.dart';
import '../providers/profile_provider.dart';

/// Customer profile screen — view and edit basic info.
class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState
    extends ConsumerState<CustomerProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isEditing = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.neonCyan),
              onPressed: () {
                final p = profileAsync.valueOrNull;
                if (p != null) {
                  _nameCtrl.text = p.fullName ?? '';
                  _emailCtrl.text = p.email ?? '';
                  setState(() => _isEditing = true);
                }
              },
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Avatar with trust-badge ring ──
                GestureDetector(
                  onTap: _isEditing ? _pickAvatar : null,
                  child: TrustBadges(
                    avatarRadius: 52,
                    isVerified: profile.verificationStatus == 'verified',
                    isPro: profile.isPro,
                    tier: profile.tier,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.bgSurface,
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? const Icon(Icons.person, size: 48,
                              color: AppColors.neonCyan)
                          : null,
                    ),
                  ),
                ),
                if (_isEditing)
                  TextButton(
                    onPressed: _pickAvatar,
                    child: const Text('Change photo',
                        style: TextStyle(color: AppColors.neonCyan)),
                  ),
                const SizedBox(height: 24),

                // ── Info card ──
                NeonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _isEditing
                        ? _buildEditForm()
                        : _buildProfileInfo(profile),
                  ),
                ),

                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  NeonButton(
                    label: 'Save Changes',
                    isLoading: _saving,
                    onPressed: () => _saveProfile(),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _isEditing = false),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],

                // ── Verify identity CTA ──
                if (!_isEditing &&
                    profile.verificationStatus != 'verified') ...[
                  const SizedBox(height: 24),
                  NeonCard(
                    child: InkWell(
                      onTap: () {
                        if (profile.verificationStatus ==
                            'duplicate_detected') {
                          context.pushNamed('duplicate-recovery');
                        } else {
                          context.pushNamed('verification');
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.neonCyan.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.shield,
                                  color: AppColors.neonCyan, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Verify your identity',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 2),
                                  Text(
                                      'Short video + a photo of your ID. Earns the verified badge.',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: AppColors.neonCyan, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // ── Become a Worker Card ──
                if (!_isEditing) ...[
                  const SizedBox(height: 24),
                  NeonCard(
                    child: InkWell(
                      onTap: () => context.pushNamed('worker-onboarding'),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.construction,
                                  color: AppColors.neonGreen, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Become a Worker',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                      'Offer your skills and earn on Waddek',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: AppColors.neonGreen, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfo(profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.person, 'Name',
            profile.fullName ?? 'Not set'),
        const Divider(color: AppColors.bgSurface, height: 24),
        _infoRow(Icons.phone, 'Phone', profile.phone),
        const Divider(color: AppColors.bgSurface, height: 24),
        _infoRow(Icons.email, 'Email',
            profile.email ?? 'Not set'),
        const Divider(color: AppColors.bgSurface, height: 24),
        _infoRow(Icons.calendar_today, 'Joined',
            profile.createdAt?.toString().split(' ').first ?? '—'),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(
          controller: _nameCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person, color: AppColors.neonCyan),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email (optional)',
            prefixIcon: Icon(Icons.email, color: AppColors.neonCyan),
          ),
        ),
      ],
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
              leading: const Icon(Icons.photo_camera,
                  color: AppColors.neonCyan),
              title: const Text('Take photo',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: AppColors.neonCyan),
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

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final fields = <String, dynamic>{};
      if (_nameCtrl.text.isNotEmpty) fields['full_name'] = _nameCtrl.text;
      if (_emailCtrl.text.isNotEmpty) fields['email'] = _emailCtrl.text;
      await ref.read(currentProfileProvider.notifier).updateProfile(fields);
      setState(() => _isEditing = false);
    } finally {
      setState(() => _saving = false);
    }
  }
}

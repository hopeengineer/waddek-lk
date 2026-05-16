import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/utils/validators.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/trust_badges.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../verification/presentation/widgets/reverify_required_sheet.dart';
import '../../domain/profile_model.dart';
import '../providers/profile_provider.dart';

/// Customer profile — per-field inline editing. There is no global
/// "edit mode": each row has its own pencil that opens just the
/// flow that field requires.
///
///   * Name   → simple inline editor when unlocked; re-verify sheet
///              when identityLocked (rule: ID name is the locked one).
///   * Phone  → bottom sheet that stages the new number and routes
///              to the OTP-verify-phone-change screen. Live phone is
///              only swapped after OTP succeeds (see edge fn).
///   * Email  → bottom sheet that triggers Supabase's confirmation
///              link flow. Live email only moves after the user
///              clicks the link.
///   * Avatar → tap on the avatar opens the picker; if locked, the
///              re-verify sheet is shown first.
class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState
    extends ConsumerState<CustomerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProfile)),
      body: profileAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text(l10n.noProfileFound));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Avatar with trust-badge ring ──
                GestureDetector(
                  onTap: _pickAvatar,
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
                          ? const Icon(Icons.person,
                              size: 48, color: AppColors.neonCyan)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (profile.identityLocked && profile.avatarUrl != null)
                  TextButton.icon(
                    onPressed: _pickAvatar, // triggers re-verify sheet
                    icon: const Icon(Icons.lock_reset,
                        size: 16, color: AppColors.neonAmber),
                    label: const Text(
                      'Re-verify to change picture',
                      style: TextStyle(
                          color: AppColors.neonAmber, fontSize: 12),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: _pickAvatar,
                    icon: const Icon(Icons.camera_alt,
                        size: 14, color: AppColors.neonCyan),
                    label: const Text(
                      'Change photo',
                      style: TextStyle(
                          color: AppColors.neonCyan, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),

                // ── Info card with per-field edit affordances ──
                NeonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _EditableRow(
                          icon: Icons.person,
                          label: 'Name',
                          value: profile.fullName ?? 'Not set',
                          locked: profile.identityLocked,
                          onEdit: () => _editName(profile),
                        ),
                        const Divider(color: AppColors.bgSurface, height: 22),
                        _EditableRow(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: profile.phone,
                          pendingValue: profile.pendingPhone,
                          onEdit: () => _editPhone(profile),
                        ),
                        const Divider(color: AppColors.bgSurface, height: 22),
                        _EditableRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: profile.email ?? 'Not set',
                          pendingValue: profile.pendingEmail,
                          onEdit: () => _editEmail(profile),
                        ),
                        const Divider(color: AppColors.bgSurface, height: 22),
                        _EditableRow(
                          icon: Icons.calendar_today,
                          label: 'Joined',
                          value: profile.createdAt
                                  ?.toString()
                                  .split(' ')
                                  .first ??
                              '—',
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Default address card ──
                const SizedBox(height: 16),
                NeonCard(
                  child: InkWell(
                    onTap: () => context.pushNamed('update-location'),
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
                            child: const Icon(Icons.location_on,
                                color: AppColors.neonCyan, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Default address',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  (profile.addressText?.isNotEmpty ?? false)
                                      ? profile.addressText!
                                      : (profile.latitude != null
                                          ? 'Coordinates set — tap to add address'
                                          : 'Not set — tap to add'),
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit,
                              color: AppColors.neonCyan, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Verify identity CTA ──
                if (profile.verificationStatus != 'verified') ...[
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.verifyIdentity,
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  const Text(
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

                // ── Become a Worker Card ── (hidden for returning workers)
                if (profile.role != 'worker' && profile.nicNumber == null) ...[
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
                                  Text(l10n.becomeAWorker,
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(l10n.becomeAWorkerDesc,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: AppColors.neonGreen, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // ── Settings ──
                const SizedBox(height: 24),
                NeonCard(
                  child: ListTile(
                    leading: const Icon(Icons.settings,
                        color: AppColors.neonCyan),
                    title: Text(l10n.settings,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                    onTap: () => context.push('/settings'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Name edit ───────────────────────────────────────────────
  Future<void> _editName(ProfileModel profile) async {
    if (profile.identityLocked) {
      final chose = await showReVerifyRequiredSheet(
        context,
        lockedField: 'name',
      );
      if (mounted) handleReVerifyChoice(context, chose);
      return;
    }
    final ctrl = TextEditingController(text: profile.fullName ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Edit name',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Your full name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty) return;
    try {
      await ref
          .read(currentProfileProvider.notifier)
          .updateProfile({'full_name': newName});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

  // ── Phone edit ──────────────────────────────────────────────
  Future<void> _editPhone(ProfileModel profile) async {
    final newPhone = await _promptForValue(
      title: 'Change phone',
      explainer:
          'We will send an OTP to the new number. Your current phone stays in place until you verify the code.',
      currentValue: profile.phone,
      hint: '+94 70 123 4567',
      keyboardType: TextInputType.phone,
    );
    if (newPhone == null || newPhone.isEmpty) return;

    final normalized = Validators.normalizePhone(newPhone);
    if (normalized == profile.phone) return;

    final ok = await ref
        .read(authProvider.notifier)
        .sendPhoneChangeOtp(normalized);
    if (!mounted) return;
    if (!ok) {
      final err = ref.read(authProvider).errorMessage ??
          'Could not send code.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.neonRed),
      );
      return;
    }
    await context.pushNamed('otp-verify-phone-change', extra: normalized);
    if (mounted) {
      await ref.read(currentProfileProvider.notifier).loadProfile();
    }
  }

  // ── Email edit ──────────────────────────────────────────────
  Future<void> _editEmail(ProfileModel profile) async {
    final newEmail = await _promptForValue(
      title: 'Change email',
      explainer:
          'A confirmation link will be sent to the new address. Your current email stays in place until you click the link.',
      currentValue: profile.email ?? '',
      hint: 'you@example.com',
      keyboardType: TextInputType.emailAddress,
    );
    if (newEmail == null || newEmail.isEmpty) return;
    if (newEmail == (profile.email ?? '')) return;
    try {
      await ref.read(authRepositoryProvider).requestEmailChange(newEmail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Confirmation link sent to the new email address.'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        await ref.read(currentProfileProvider.notifier).loadProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start change: $e'),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

  /// Generic bottom-sheet prompt with explainer + single text field
  /// + Cancel/Continue actions. Used for phone & email entry.
  Future<String?> _promptForValue({
    required String title,
    required String explainer,
    required String currentValue,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final ctrl = TextEditingController(text: currentValue);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(explainer,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType: keyboardType,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: AppColors.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              NeonButton(
                label: 'Continue',
                icon: Icons.arrow_forward,
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Avatar ──────────────────────────────────────────────────
  Future<void> _pickAvatar() async {
    final p = ref.read(currentProfileProvider).valueOrNull;
    if (p != null && p.identityLocked && p.avatarUrl != null) {
      final chose = await showReVerifyRequiredSheet(
        context,
        lockedField: 'profile picture',
      );
      if (mounted) handleReVerifyChoice(context, chose);
      return;
    }

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
      final bytes = await picked.readAsBytes();
      await ref.read(currentProfileProvider.notifier).uploadAvatar(bytes);
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
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.icon,
    required this.label,
    required this.value,
    this.pendingValue,
    this.locked = false,
    this.readOnly = false,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? pendingValue;
  final bool locked;
  final bool readOnly;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 16)),
              if (pendingValue != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Pending: $pendingValue',
                  style: const TextStyle(
                      color: AppColors.neonAmber, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
        if (readOnly)
          const SizedBox.shrink()
        else if (locked)
          IconButton(
            icon: const Icon(Icons.lock,
                color: AppColors.neonGreen, size: 18),
            tooltip: 'Locked — tap to re-verify',
            onPressed: onEdit,
          )
        else
          IconButton(
            icon: const Icon(Icons.edit,
                color: AppColors.neonCyan, size: 18),
            tooltip: 'Edit',
            onPressed: onEdit,
          ),
      ],
    );
  }
}

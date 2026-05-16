import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/providers/locale_provider.dart';
import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';

/// Account / app settings. Language picker and logout for now —
/// notification preferences and account deletion can hang off this.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader(l10n.language),
          NeonCard(
            child: Column(
              children: [
                _localeTile(ref, locale, 'English', const Locale('en')),
                const Divider(color: AppColors.bgSurface, height: 1),
                _localeTile(ref, locale, 'සිංහල (Sinhala)',
                    const Locale('si')),
                const Divider(color: AppColors.bgSurface, height: 1),
                _localeTile(ref, locale, 'தமிழ் (Tamil)',
                    const Locale('ta')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(l10n.account),
          NeonCard(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.neonRed),
              title: Text(l10n.logOut,
                  style: const TextStyle(
                      color: AppColors.neonRed,
                      fontWeight: FontWeight.w600)),
              onTap: () => _confirmLogout(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(l10n.about),
          NeonCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppColors.neonCyan),
                  title: Text(l10n.version,
                      style: const TextStyle(color: AppColors.textPrimary)),
                  trailing: const Text('1.0.0',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4),
      ),
    );
  }

  Widget _localeTile(
      WidgetRef ref, Locale current, String label, Locale value) {
    final selected = current.languageCode == value.languageCode;
    return ListTile(
      title: Text(label,
          style: const TextStyle(color: AppColors.textPrimary)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.neonCyan)
          : const Icon(Icons.radio_button_unchecked,
              color: AppColors.textSecondary),
      onTap: () => ref.read(localeProvider.notifier).setLocale(value),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text(l10n.logOutTitle,
              style: const TextStyle(color: AppColors.textPrimary)),
          content: Text(l10n.logOutMessage,
              style: const TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.logOut,
                  style: const TextStyle(color: AppColors.neonRed)),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    await ref.read(authProvider.notifier).signOut();
    if (context.mounted) {
      context.go('/auth/login');
    }
  }
}

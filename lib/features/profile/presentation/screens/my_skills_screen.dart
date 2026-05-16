import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';
import '../providers/profile_provider.dart';

/// Worker manages their selected service categories.
class MySkillsScreen extends ConsumerStatefulWidget {
  const MySkillsScreen({super.key});

  @override
  ConsumerState<MySkillsScreen> createState() => _MySkillsScreenState();
}

class _MySkillsScreenState extends ConsumerState<MySkillsScreen> {
  Set<String> _selected = {};
  bool _initialized = false;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .setWorkerCategories(
            workerId: ref.read(currentProfileProvider).value!.id,
            categoryIds: _selected.toList(),
          );
      // Refresh anything that reads worker categories.
      final me = ref.read(currentProfileProvider).valueOrNull;
      if (me != null) {
        ref.invalidate(workerSkillsProvider(me.id));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skills updated.'),
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
              backgroundColor: AppColors.neonRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentProfileProvider).valueOrNull;
    if (me == null) {
      return const Scaffold(body: Center(child: LoadingShimmer()));
    }
    final categoriesAsync = ref.watch(categoriesProvider);
    final mySkillsAsync = ref.watch(workerSkillsProvider(me.id));

    // Seed selection from server once.
    mySkillsAsync.whenData((rows) {
      if (!_initialized) {
        _selected = rows
            .map<String>((r) => r['category_id'] as String)
            .toSet();
        _initialized = true;
      }
    });

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mySkills)),
      body: categoriesAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (categories) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pick the services you offer. You\'ll be notified of jobs in these categories.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final cat = categories[i];
                    final id = cat['id'] as String;
                    final name = cat['name_en'] as String? ?? 'Category';
                    final isSelected = _selected.contains(id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(id);
                          } else {
                            _selected.remove(id);
                          }
                        });
                      },
                      title: Text(name,
                          style: const TextStyle(
                              color: AppColors.textPrimary)),
                      activeColor: AppColors.neonCyan,
                      checkColor: AppColors.bgDark,
                      tileColor: AppColors.bgSurface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: NeonButton(
            label: 'Save (${_selected.length} selected)',
            icon: Icons.check,
            isLoading: _saving,
            onPressed: _selected.isEmpty ? null : _save,
          ),
        ),
      ),
    );
  }
}

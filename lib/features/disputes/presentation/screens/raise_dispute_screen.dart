import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/features/disputes/presentation/providers/disputes_provider.dart';

/// Raise dispute screen.
class RaiseDisputeScreen extends ConsumerStatefulWidget {
  const RaiseDisputeScreen({super.key, required this.jobId});
  final String jobId;

  @override
  ConsumerState<RaiseDisputeScreen> createState() =>
      _RaiseDisputeScreenState();
}

class _RaiseDisputeScreenState extends ConsumerState<RaiseDisputeScreen> {
  String? _selectedReason;
  final _descController = TextEditingController();
  bool _submitting = false;

  static const _reasons = [
    'Worker did not show up',
    'Poor quality work',
    'Overcharged for the job',
    'Rude or unprofessional behavior',
    'Damage to property',
    'Safety concern',
    'Other',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What went wrong?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select the reason that best describes your issue.',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // ── Reason Chips ──
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reasons.map((r) {
                final selected = _selectedReason == r;
                return ChoiceChip(
                  label: Text(r),
                  selected: selected,
                  selectedColor: AppColors.neonRed.withOpacity(0.2),
                  backgroundColor: AppColors.bgSurface,
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.neonRed
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppColors.neonRed.withOpacity(0.5)
                        : Colors.transparent,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedReason = r),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Description ──
            const Text('Details',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe what happened...',
                hintStyle:
                    const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Evidence Upload ──
            NeonCard(
              child: ListTile(
                leading: const Icon(Icons.add_a_photo,
                    color: AppColors.neonCyan),
                title: const Text('Add Evidence (Optional)',
                    style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('Photos help us investigate faster',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
                onTap: () {
                  // TODO: Image picker for evidence
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── Warning ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neonAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.neonAmber.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline,
                      color: AppColors.neonAmber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'False reports may result in account restrictions.',
                      style: TextStyle(
                          color: AppColors.neonAmber, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ──
            NeonButton(
              label: 'Submit Report',
              isLoading: _submitting,
              onPressed: _selectedReason == null ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(disputesRepositoryProvider).raiseDispute(
            jobId: widget.jobId,
            reason: _selectedReason!,
            description: _descController.text.trim().isNotEmpty
                ? _descController.text.trim()
                : null,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. We\'ll investigate shortly.'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: AppColors.neonRed),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

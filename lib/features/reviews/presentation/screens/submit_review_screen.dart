import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/features/reviews/presentation/providers/reviews_provider.dart';

/// Submit review screen — prompted after job completion.
class SubmitReviewScreen extends ConsumerStatefulWidget {
  const SubmitReviewScreen({
    super.key,
    required this.jobId,
    required this.workerId,
  });
  final String jobId;
  final String workerId;

  @override
  ConsumerState<SubmitReviewScreen> createState() =>
      _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends ConsumerState<SubmitReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave a Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'How was the service?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your review helps workers improve and customers choose better.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // ── Star Rating ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starIndex = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      starIndex <= _rating
                          ? Icons.star
                          : Icons.star_border,
                      color: starIndex <= _rating
                          ? AppColors.neonAmber
                          : AppColors.textSecondary,
                      size: 44,
                    ),
                  ),
                );
              }),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Text(
                _ratingLabel(_rating),
                style: const TextStyle(
                    color: AppColors.neonAmber,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 24),

            // ── Comment ──
            TextField(
              controller: _commentController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us more (optional)...',
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
            const SizedBox(height: 32),

            // ── Submit ──
            NeonButton(
              label: 'Submit Review',
              isLoading: _submitting,
              onPressed: _rating == 0 ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor 😟';
      case 2:
        return 'Below Average';
      case 3:
        return 'Average';
      case 4:
        return 'Good 👍';
      case 5:
        return 'Excellent! ⭐';
      default:
        return '';
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(reviewsRepositoryProvider).submitReview(
            jobId: widget.jobId,
            workerId: widget.workerId,
            rating: _rating,
            comment: _commentController.text.trim().isNotEmpty
                ? _commentController.text.trim()
                : null,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted! Thank you 🙏'),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/features/profile/presentation/providers/profile_provider.dart';
import '../providers/jobs_provider.dart';

/// Customer: create a new job request.
class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetMinCtrl = TextEditingController();
  final _budgetMaxCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _selectedCategoryId;
  bool _saving = false;
  bool _locating = false;
  final List<XFile> _photos = [];

  // Default location — Colombo city center (will be replaced by user's location)
  double _lat = 6.9271;
  double _lng = 79.8612;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _budgetMinCtrl.dispose();
    _budgetMaxCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Post a Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Category ──
            const Text('Category *',
                style: TextStyle(
                    color: AppColors.neonCyan, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            categoriesAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Text('Error: $e'),
              data: (cats) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cats.map((c) {
                  final id = c['id'] as String;
                  final selected = _selectedCategoryId == id;
                  return ChoiceChip(
                    label: Text(c['name_en'] as String),
                    selected: selected,
                    selectedColor: AppColors.neonCyan.withOpacity(0.25),
                    backgroundColor: AppColors.bgSurface,
                    labelStyle: TextStyle(
                      color: selected
                          ? AppColors.neonCyan
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color:
                          selected ? AppColors.neonCyan : AppColors.bgSurface,
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedCategoryId = id),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Title ──
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                hintText: 'e.g. Fix leaking tap in kitchen',
                prefixIcon: Icon(Icons.work, color: AppColors.neonCyan),
              ),
            ),
            const SizedBox(height: 16),

            // ── Description ──
            TextField(
              controller: _descCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Describe the job in detail...',
                prefixIcon:
                    Icon(Icons.description, color: AppColors.neonCyan),
              ),
            ),
            const SizedBox(height: 16),

            // ── Budget Range ──
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _budgetMinCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Budget (Rs.)',
                      prefixIcon:
                          Icon(Icons.money, color: AppColors.neonCyan),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _budgetMaxCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Budget (Rs.)',
                      prefixIcon:
                          Icon(Icons.money, color: AppColors.neonCyan),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Address ──
            TextField(
              controller: _addressCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Where is the job?',
                prefixIcon:
                    Icon(Icons.location_on, color: AppColors.neonCyan),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: _locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.neonCyan),
                    )
                  : const Icon(Icons.my_location,
                      color: AppColors.neonCyan, size: 18),
              label: const Text('Use current location',
                  style: TextStyle(color: AppColors.neonCyan)),
              onPressed: _locating ? null : _useCurrentLocation,
            ),
            const SizedBox(height: 24),

            // ── Photos ──
            NeonCard(
              child: InkWell(
                onTap: _pickPhotos,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate,
                          color: AppColors.neonCyan, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        _photos.isEmpty
                            ? 'Add Photos (optional)'
                            : '${_photos.length} photo${_photos.length == 1 ? '' : 's'} attached',
                        style: const TextStyle(
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit ──
            NeonButton(
              label: 'Post Job',
              isLoading: _saving,
              onPressed: _submitJob,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitJob() async {
    if (_selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      _showError('Please enter a title');
      return;
    }

    setState(() => _saving = true);
    try {
      final profile = ref.read(currentProfileProvider).valueOrNull;
      if (profile == null) {
        _showError('Profile not loaded');
        return;
      }

      final job =
          await ref.read(customerJobsProvider.notifier).createJob(
                customerId: profile.id,
                categoryId: _selectedCategoryId!,
                title: _titleCtrl.text.trim(),
                description: _descCtrl.text.trim().isNotEmpty
                    ? _descCtrl.text.trim()
                    : null,
                latitude: _lat,
                longitude: _lng,
                address: _addressCtrl.text.trim().isNotEmpty
                    ? _addressCtrl.text.trim()
                    : null,
                budgetMin: double.tryParse(_budgetMinCtrl.text),
                budgetMax: double.tryParse(_budgetMaxCtrl.text),
              );

      // Upload photos (if any) after the job exists, then attach URLs.
      if (_photos.isNotEmpty) {
        final repo = ref.read(jobsRepositoryProvider);
        final urls = await repo.uploadJobPhotos(
          jobId: job.id,
          filePaths: _photos.map((p) => p.path).toList(),
        );
        await repo.setJobPhotos(job.id, urls);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted.'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        context.pop(); // Go back
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _showError('Location permission denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location set.'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
      }
    } catch (e) {
      _showError('Could not get location: $e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage(
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked.isEmpty) return;
    setState(() {
      _photos
        ..clear()
        ..addAll(picked);
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.neonRed),
    );
  }
}

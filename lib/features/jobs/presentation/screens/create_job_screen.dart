import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:waddek_lk/core/services/places_service.dart';
import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/address_lookup_field.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/features/profile/presentation/providers/profile_provider.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';
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
    final profileAsync = ref.watch(currentProfileProvider);
    final profile = profileAsync.valueOrNull;
    final isVerified = profile?.verificationStatus == 'verified';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.postJob)),
      body: profileAsync.isLoading
          ? const LoadingShimmer()
          : !isVerified
              ? _VerifyToPostGate(status: profile?.verificationStatus)
              : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Category ──
            Text('${l10n.category} *',
                style: const TextStyle(
                    color: AppColors.neonCyan, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            categoriesAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Text('${l10n.error}: $e'),
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
              decoration: InputDecoration(
                labelText: '${l10n.jobTitle} *',
                hintText: l10n.jobTitleHint,
                prefixIcon: const Icon(Icons.work, color: AppColors.neonCyan),
              ),
            ),
            const SizedBox(height: 16),

            // ── Description ──
            TextField(
              controller: _descCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.descriptionOptional,
                hintText: l10n.descriptionHint,
                prefixIcon:
                    const Icon(Icons.description, color: AppColors.neonCyan),
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
                    decoration: InputDecoration(
                      labelText: l10n.minBudget,
                      prefixIcon: const Icon(Icons.money,
                          color: AppColors.neonCyan),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _budgetMaxCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.maxBudget,
                      prefixIcon: const Icon(Icons.money,
                          color: AppColors.neonCyan),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Address ──
            AddressLookupField(
              controller: _addressCtrl,
              label: l10n.address,
              hint: l10n.addressHint,
              onSelected: (addr, lat, lng) {
                setState(() {
                  _lat = lat;
                  _lng = lng;
                });
              },
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
              label: Text(l10n.useCurrentLocation,
                  style: const TextStyle(color: AppColors.neonCyan)),
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
                            ? l10n.addPhotosOptional
                            : l10n.photosAttached(_photos.length),
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
              label: l10n.postJob,
              isLoading: _saving,
              onPressed: _submitJob,
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _submitJob() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCategoryId == null) {
      _showError(l10n.selectCategory);
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      _showError(l10n.enterTitle);
      return;
    }

    setState(() => _saving = true);
    try {
      final profile = ref.read(currentProfileProvider).valueOrNull;
      if (profile == null) {
        _showError(l10n.profileNotLoaded);
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
          SnackBar(
            content: Text(l10n.jobPosted),
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
    final l10n = AppLocalizations.of(context)!;
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _showError(l10n.locationPermissionDenied);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final address =
          await PlacesService.reverseGeocode(pos.latitude, pos.longitude);
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        if (address != null && address.isNotEmpty) {
          _addressCtrl.text = address;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.locationSet),
            backgroundColor: AppColors.neonGreen,
          ),
        );
      }
    } catch (e) {
      _showError('${l10n.error}: $e');
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

/// Verification gate shown in place of the job form for unverified users.
class _VerifyToPostGate extends StatelessWidget {
  const _VerifyToPostGate({required this.status});
  final String? status;

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';
    final isDuplicate = status == 'duplicate_detected';

    final headline = isPending
        ? 'Verification in progress'
        : isDuplicate
            ? 'Existing account detected'
            : 'Verify your identity to post a job';
    final body = isPending
        ? 'Finish the verification step in your browser tab. Once it clears, you can post jobs.'
        : isDuplicate
            ? 'Your ID is already linked to another account. Recover it to continue.'
            : 'We ask every customer to verify once. It takes about a minute and keeps the marketplace safe for workers.';
    final ctaLabel = isDuplicate ? 'Recover account' : 'Verify identity';
    final ctaRoute = isDuplicate ? 'duplicate-recovery' : 'verification';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: NeonCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined,
                    size: 56, color: AppColors.neonAmber),
                const SizedBox(height: 16),
                Text(headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 20),
                NeonButton(
                  label: ctaLabel,
                  icon: Icons.videocam,
                  onPressed: () => context.pushNamed(ctaRoute),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

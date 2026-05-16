import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/providers/role_provider.dart';
import '../providers/profile_provider.dart';

/// Multi-step worker onboarding: name → NIC → skills → location.
class WorkerOnboardingScreen extends ConsumerStatefulWidget {
  const WorkerOnboardingScreen({super.key});

  @override
  ConsumerState<WorkerOnboardingScreen> createState() =>
      _WorkerOnboardingScreenState();
}

class _WorkerOnboardingScreenState
    extends ConsumerState<WorkerOnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentStep = 0;
  bool _saving = false;

  // Step 1: Basic Info
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  // Step 2: NIC — store bytes directly so this works on web too
  // (dart:io.File throws on Flutter web; XFile.readAsBytes() doesn't).
  final _nicNumberCtrl = TextEditingController();
  Uint8List? _nicFrontBytes;
  Uint8List? _nicBackBytes;

  // Step 3: Skills
  final Set<String> _selectedCategoryIds = {};

  /// Steps shown to the user. Verified users skip the in-app NIC step
  /// since their identity is already on file from Shufti.
  List<_OnboardingStep> _stepsFor({required bool isVerified}) {
    return [
      _OnboardingStep(
          key: 'basicInfo',
          title: 'Basic Info',
          build: _buildBasicInfoStep),
      if (!isVerified)
        _OnboardingStep(
            key: 'nic',
            title: 'Identity Verification',
            build: _buildNicStep),
      _OnboardingStep(
          key: 'skills',
          title: 'Select Your Skills',
          build: _buildSkillsStep),
      _OnboardingStep(
          key: 'location',
          title: 'Set Your Location',
          build: _buildLocationStep),
    ];
  }

  bool get _isVerified =>
      ref.read(currentProfileProvider).valueOrNull?.verificationStatus ==
      'verified';

  @override
  void initState() {
    super.initState();
    // Seed name / bio from the existing profile so verified users don't
    // have to retype what's already on their account. The name field
    // becomes read-only for verified users (identity is locked).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(currentProfileProvider).valueOrNull;
      if (profile == null) return;
      if (_nameCtrl.text.isEmpty && (profile.fullName?.isNotEmpty ?? false)) {
        _nameCtrl.text = profile.fullName!;
      }
      if (_bioCtrl.text.isEmpty && (profile.bio?.isNotEmpty ?? false)) {
        _bioCtrl.text = profile.bio!;
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _nicNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = ref
            .watch(currentProfileProvider)
            .valueOrNull
            ?.verificationStatus ==
        'verified';
    final steps = _stepsFor(isVerified: isVerified);

    // If verification status changed mid-session and the active index is
    // now out of range, clamp it.
    if (_currentStep >= steps.length) _currentStep = steps.length - 1;
    final isLastStep = _currentStep == steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of ${steps.length}'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: Column(
        children: [
          // ── Progress Bar ──
          _buildProgressBar(steps.length),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              steps[_currentStep].title,
              style: const TextStyle(
                color: AppColors.neonCyan,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Steps ──
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: steps.map((s) => s.build()).toList(),
            ),
          ),

          // ── Next / Finish Button ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: NeonButton(
              label: isLastStep ? 'Finish Setup' : 'Continue',
              isLoading: _saving,
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(total, (i) {
          final isActive = i <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? AppColors.neonCyan : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Basic Info ──
  Widget _buildBasicInfoStep() {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final isVerified = profile?.verificationStatus == 'verified';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            readOnly: isVerified,
            style: TextStyle(
              color: isVerified
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Full Name *',
              helperText: isVerified
                  ? 'Locked — taken from your verified ID'
                  : null,
              helperStyle:
                  const TextStyle(color: AppColors.neonPurple, fontSize: 11),
              prefixIcon:
                  const Icon(Icons.person, color: AppColors.neonCyan),
              suffixIcon: isVerified
                  ? const Icon(Icons.lock,
                      color: AppColors.neonPurple, size: 18)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Bio (optional)',
              hintText: 'Describe your experience...',
              prefixIcon: Icon(Icons.description, color: AppColors.neonCyan),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: NIC Upload ──
  Widget _buildNicStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload your National Identity Card for verification',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nicNumberCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'NIC Number *',
              prefixIcon: Icon(Icons.badge, color: AppColors.neonCyan),
            ),
          ),
          const SizedBox(height: 20),
          _buildUploadCard(
            label: 'NIC Front',
            icon: Icons.credit_card,
            uploaded: _nicFrontBytes != null,
            onTap: () => _pickNicPhoto(true),
          ),
          const SizedBox(height: 12),
          _buildUploadCard(
            label: 'NIC Back',
            icon: Icons.credit_card,
            uploaded: _nicBackBytes != null,
            onTap: () => _pickNicPhoto(false),
          ),
          const SizedBox(height: 12),
          NeonCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: const [
                  Icon(Icons.security, color: AppColors.neonGreen, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your NIC is securely stored and used only for verification.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required String label,
    required IconData icon,
    required bool uploaded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: NeonCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon,
                  color: uploaded ? AppColors.neonGreen : AppColors.neonCyan,
                  size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 16)),
                    Text(
                      uploaded ? 'Photo selected' : 'Tap to upload',
                      style: TextStyle(
                        color: uploaded
                            ? AppColors.neonGreen
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.camera_alt,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 3: Skills ──
  Widget _buildSkillsStep() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const LoadingShimmer(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (categories) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select the services you offer (choose at least one)',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final catId = cat['id'] as String;
                  final isSelected = _selectedCategoryIds.contains(catId);
                  return FilterChip(
                    label: Text(cat['name_en'] as String),
                    selected: isSelected,
                    selectedColor: AppColors.neonCyan.withOpacity(0.25),
                    checkmarkColor: AppColors.neonCyan,
                    backgroundColor: AppColors.bgSurface,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.bgSurface,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategoryIds.add(catId);
                        } else {
                          _selectedCategoryIds.remove(catId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                '${_selectedCategoryIds.length} selected',
                style: const TextStyle(
                    color: AppColors.neonCyan, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Step 4: Location ──
  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Icon(Icons.location_on, color: AppColors.neonCyan, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Enable Location',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We need your location to show you nearby jobs and help customers find workers in their area.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          NeonCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _locationBenefit(Icons.work, 'Get matched with nearby jobs'),
                  const SizedBox(height: 12),
                  _locationBenefit(Icons.trending_up, 'Appear in local search results'),
                  const SizedBox(height: 12),
                  _locationBenefit(Icons.speed, 'Faster job matching'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationBenefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  // ── Navigation ──

  void _nextStep() async {
    final steps = _stepsFor(isVerified: _isVerified);
    final currentKey = steps[_currentStep].key;

    // Validate current step
    if (currentKey == 'basicInfo' && _nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (currentKey == 'skills' && _selectedCategoryIds.isEmpty) {
      _showError('Please select at least one skill');
      return;
    }

    if (_currentStep < steps.length - 1) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final step — save everything
      await _finishOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() => _saving = true);
    try {
      final notifier = ref.read(currentProfileProvider.notifier);

      // Update basic info + promote to worker. Setting role='worker'
      // here means subsequent role toggles recognise the user as a
      // registered worker and skip onboarding (verified users complete
      // a NIC-less flow, so we can't rely on nic_number as the
      // "onboarded" signal).
      await notifier.updateProfile({
        'role': 'worker',
        'full_name': _nameCtrl.text.trim(),
        if (_bioCtrl.text.isNotEmpty) 'bio': _bioCtrl.text.trim(),
      });

      // Upload NIC if provided
      if (_nicFrontBytes != null &&
          _nicBackBytes != null &&
          _nicNumberCtrl.text.isNotEmpty) {
        await notifier.uploadNic(
          frontBytes: _nicFrontBytes!,
          backBytes: _nicBackBytes!,
          nicNumber: _nicNumberCtrl.text.trim(),
        );
      }

      // Set categories
      if (_selectedCategoryIds.isNotEmpty) {
        await notifier.setCategories(_selectedCategoryIds.toList());
      }

      // Request location
      try {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.whileInUse ||
            perm == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          await notifier.updateLocation(
            lat: pos.latitude,
            lng: pos.longitude,
          );
        }
      } catch (_) {
        // Location is optional — continue even if denied
      }

      // Activate worker role
      await ref.read(activeRoleProvider.notifier).switchRole('worker');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome, Worker! You\'re all set.'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        context.go('/worker/jobs');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _pickNicPhoto(bool isFront) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        if (isFront) {
          _nicFrontBytes = bytes;
        } else {
          _nicBackBytes = bytes;
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: AppColors.neonRed),
    );
  }
}

/// One step in the worker onboarding wizard.
class _OnboardingStep {
  const _OnboardingStep({
    required this.key,
    required this.title,
    required this.build,
  });

  final String key;
  final String title;
  final Widget Function() build;
}

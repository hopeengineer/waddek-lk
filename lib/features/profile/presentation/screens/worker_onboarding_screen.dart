import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
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

  // Step 2: NIC
  final _nicNumberCtrl = TextEditingController();
  String? _nicFrontPath;
  String? _nicBackPath;

  // Step 3: Skills
  final Set<String> _selectedCategoryIds = {};

  final _stepTitles = [
    'Basic Info',
    'Identity Verification',
    'Select Your Skills',
    'Set Your Location',
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of 4'),
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
          _buildProgressBar(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _stepTitles[_currentStep],
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
              children: [
                _buildBasicInfoStep(),
                _buildNicStep(),
                _buildSkillsStep(),
                _buildLocationStep(),
              ],
            ),
          ),

          // ── Next / Finish Button ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: NeonButton(
              label: _currentStep == 3 ? 'Finish Setup' : 'Continue',
              isLoading: _saving,
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(4, (i) {
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
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: Icon(Icons.person, color: AppColors.neonCyan),
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
            path: _nicFrontPath,
            onTap: () => _pickNicPhoto(true),
          ),
          const SizedBox(height: 12),
          _buildUploadCard(
            label: 'NIC Back',
            icon: Icons.credit_card,
            path: _nicBackPath,
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
    required String? path,
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
                  color: path != null ? AppColors.neonGreen : AppColors.neonCyan,
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
                      path != null ? 'Photo selected ✓' : 'Tap to upload',
                      style: TextStyle(
                        color: path != null
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
    // Validate current step
    if (_currentStep == 0 && _nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (_currentStep == 2 && _selectedCategoryIds.isEmpty) {
      _showError('Please select at least one skill');
      return;
    }

    if (_currentStep < 3) {
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

      // Update basic info
      await notifier.updateProfile({
        'full_name': _nameCtrl.text.trim(),
        if (_bioCtrl.text.isNotEmpty) 'bio': _bioCtrl.text.trim(),
      });

      // Upload NIC if provided
      if (_nicFrontPath != null &&
          _nicBackPath != null &&
          _nicNumberCtrl.text.isNotEmpty) {
        await notifier.uploadNic(
          frontPath: _nicFrontPath!,
          backPath: _nicBackPath!,
          nicNumber: _nicNumberCtrl.text.trim(),
        );
      }

      // Set categories
      if (_selectedCategoryIds.isNotEmpty) {
        await notifier.setCategories(_selectedCategoryIds.toList());
      }

      // Request location
      // TODO: Use geolocator to get current position
      // final pos = await Geolocator.getCurrentPosition();
      // await notifier.updateLocation(lat: pos.latitude, lng: pos.longitude);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile setup complete! 🎉'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        // Navigate to home
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _pickNicPhoto(bool isFront) async {
    // TODO: Use image_picker
    // final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    // if (picked != null) {
    //   setState(() {
    //     if (isFront) _nicFrontPath = picked.path;
    //     else _nicBackPath = picked.path;
    //   });
    // }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: AppColors.neonRed),
    );
  }
}

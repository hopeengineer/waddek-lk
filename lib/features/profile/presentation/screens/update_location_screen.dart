import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import '../providers/profile_provider.dart';

/// Lets a worker update their service location (used for job
/// proximity matching by find_nearby_workers RPC).
class UpdateLocationScreen extends ConsumerStatefulWidget {
  const UpdateLocationScreen({super.key});

  @override
  ConsumerState<UpdateLocationScreen> createState() =>
      _UpdateLocationScreenState();
}

class _UpdateLocationScreenState
    extends ConsumerState<UpdateLocationScreen> {
  final _addressCtrl = TextEditingController();
  double? _lat;
  double? _lng;
  bool _locating = false;
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: AppColors.neonRed,
            ),
          );
        }
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not get location: $e'),
              backgroundColor: AppColors.neonRed),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please detect your location first'),
          backgroundColor: AppColors.neonRed,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(currentProfileProvider.notifier).updateLocation(
            lat: _lat!,
            lng: _lng!,
            address: _addressCtrl.text.trim().isEmpty
                ? null
                : _addressCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated.'),
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
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Update Location')),
      body: profileAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (p) {
          if (p == null) return const SizedBox.shrink();
          if (!_initialized) {
            _addressCtrl.text = p.addressText ?? '';
            _lat = p.latitude;
            _lng = p.longitude;
            _initialized = true;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NeonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on,
                                color: AppColors.neonCyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Current coordinates',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lat != null && _lng != null
                              ? '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}'
                              : 'Not set',
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                NeonButton(
                  label: 'Detect my location',
                  icon: Icons.my_location,
                  isLoading: _locating,
                  onPressed: _detectLocation,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _addressCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Address (shown to customers)',
                    hintText: 'e.g. Wellawatte, Colombo',
                    prefixIcon:
                        Icon(Icons.home, color: AppColors.neonCyan),
                  ),
                ),
                const SizedBox(height: 24),
                NeonButton(
                  label: 'Save location',
                  icon: Icons.check,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

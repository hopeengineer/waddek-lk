import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/services/places_service.dart';
import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/address_lookup_field.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';
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
  void initState() {
    super.initState();
    _addressCtrl.addListener(_onAddressChanged);
  }

  void _onAddressChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _addressCtrl.removeListener(_onAddressChanged);
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
    final typed = _addressCtrl.text.trim();
    setState(() => _saving = true);
    try {
      // Forward-geocode the typed address if the user never tapped
      // Detect or a Google suggestion — that's the only way they
      // would have a string here without coordinates attached.
      if ((_lat == null || _lng == null) && typed.isNotEmpty) {
        final details = await PlacesService.forwardGeocode(typed);
        if (details != null) {
          _lat = details.lat;
          _lng = details.lng;
          _addressCtrl.text = details.formattedAddress;
        }
      }
      if (_lat == null || _lng == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Pick a suggestion, tap Detect, or enter a more specific address.'),
              backgroundColor: AppColors.neonRed,
            ),
          );
        }
        return;
      }
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.updateLocation)),
      body: profileAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
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
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.neonCyan, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            (_addressCtrl.text.trim().isNotEmpty)
                                ? _addressCtrl.text.trim()
                                : (_lat != null
                                    ? 'Pin set — add an address below'
                                    : 'Address not set'),
                            style: const TextStyle(
                                color: AppColors.textPrimary),
                          ),
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
                AddressLookupField(
                  controller: _addressCtrl,
                  label: 'Address (shown to customers)',
                  hint: 'e.g. Wellawatte, Colombo',
                  onSelected: (addr, lat, lng) {
                    setState(() {
                      _lat = lat;
                      _lng = lng;
                    });
                  },
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

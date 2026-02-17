import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'supabase_service.dart';

/// Location service for tracking worker position with battery optimization.
class LocationService {
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;
  LocationService._();

  bool _tracking = false;

  /// Check and request location permissions.
  Future<bool> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[LocationService] Location services disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('[LocationService] Location permission permanently denied');
      return false;
    }

    return true;
  }

  /// Get current position once.
  Future<Position?> getCurrentPosition() async {
    if (!await ensurePermission()) return null;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Start tracking worker location with significant movement filter.
  /// Only updates Supabase when worker moves ~500m.
  void startTracking(String userId) {
    if (_tracking) return;
    _tracking = true;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 500, // Only update on significant movement (500m)
    );

    Geolocator.getPositionStream(locationSettings: settings).listen(
      (Position position) async {
        debugPrint(
            '[LocationService] Position: ${position.latitude}, ${position.longitude}');

        // Update in Supabase using PostGIS-compatible format
        try {
          await SupabaseService.client.from('profiles').update({
            'location':
                'POINT(${position.longitude} ${position.latitude})',
            'last_seen_at': DateTime.now().toIso8601String(),
          }).eq('id', userId);
        } catch (e) {
          debugPrint('[LocationService] Update failed: $e');
        }
      },
      onError: (e) {
        debugPrint('[LocationService] Stream error: $e');
        _tracking = false;
      },
    );

    debugPrint('[LocationService] Tracking started for $userId');
  }

  /// Stop tracking.
  void stopTracking() {
    _tracking = false;
    debugPrint('[LocationService] Tracking stopped');
  }

  bool get isTracking => _tracking;
}

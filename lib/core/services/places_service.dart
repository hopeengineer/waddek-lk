import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// One row in the autocomplete result list.
class PlacePrediction {
  PlacePrediction({required this.placeId, required this.description});
  final String placeId;
  final String description;
}

/// Resolved location for a tapped prediction.
class PlaceDetails {
  PlaceDetails({
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });
  final String formattedAddress;
  final double lat;
  final double lng;
}

class PlacesException implements Exception {
  PlacesException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Talks to the `places-proxy` Supabase edge function — which in
/// turn calls Google Places (New) + Geocoding from the server side.
/// Going through the edge function instead of calling Google
/// directly from Flutter solves three things at once:
///   * The Google API key stays in Supabase secrets, not in the
///     compiled Flutter bundle.
///   * Browser CORS is no longer an issue — the client only talks
///     to *.supabase.co, which we control.
///   * We can scope the Google key to "server applications" and
///     skip referrer/package-name allowlists entirely.
class PlacesService {
  static const _fn = 'places-proxy';

  static SupabaseClient get _client => SupabaseService.client;

  static Map<String, dynamic> _readMap(FunctionResponse res) {
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is String && data.isNotEmpty) {
      // Edge functions sometimes return raw JSON strings.
      try {
        // ignore: avoid_dynamic_calls
        final decoded = (data as dynamic);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  /// Suggest addresses for a typed query, scoped to Sri Lanka.
  static Future<List<PlacePrediction>> autocomplete(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final res = await _client.functions.invoke(
      _fn,
      body: {'op': 'autocomplete', 'input': q},
    );
    final body = _readMap(res);
    if (body['error'] != null) {
      throw PlacesException(body['error'].toString());
    }
    final suggestions = (body['suggestions'] as List?) ?? const [];
    return suggestions
        .map((s) {
          final p = (s as Map)['placePrediction'] as Map?;
          if (p == null) return null;
          final id = p['placeId'] as String?;
          final text = (p['text'] as Map?)?['text'] as String?;
          if (id == null || text == null) return null;
          return PlacePrediction(placeId: id, description: text);
        })
        .whereType<PlacePrediction>()
        .toList();
  }

  /// Resolve a place_id from autocomplete to its coordinates +
  /// formatted address.
  static Future<PlaceDetails?> details(String placeId) async {
    final res = await _client.functions.invoke(
      _fn,
      body: {'op': 'details', 'placeId': placeId},
    );
    final body = _readMap(res);
    if (body['error'] != null) {
      throw PlacesException(body['error'].toString());
    }
    final location = body['location'] as Map?;
    if (location == null) return null;
    return PlaceDetails(
      formattedAddress: body['formattedAddress'] as String? ?? '',
      lat: (location['latitude'] as num).toDouble(),
      lng: (location['longitude'] as num).toDouble(),
    );
  }

  /// Forward-geocode a typed address → lat/lng + formatted address.
  /// Save-time fallback when the user typed manually instead of
  /// picking a suggestion.
  static Future<PlaceDetails?> forwardGeocode(String address) async {
    final q = address.trim();
    if (q.isEmpty) return null;
    final res = await _client.functions.invoke(
      _fn,
      body: {'op': 'geocode', 'address': q},
    );
    final body = _readMap(res);
    if (body['error'] != null) {
      throw PlacesException(body['error'].toString());
    }
    final status = body['status'] as String?;
    if (status != 'OK') {
      if (status == 'ZERO_RESULTS') return null;
      throw PlacesException(
          'Geocoding $status. ${body['error_message'] ?? ''}');
    }
    final results = (body['results'] as List?) ?? const [];
    if (results.isEmpty) return null;
    final first = results.first as Map;
    final geom = first['geometry'] as Map?;
    final loc = geom?['location'] as Map?;
    if (loc == null) return null;
    return PlaceDetails(
      formattedAddress: first['formatted_address'] as String? ?? q,
      lat: (loc['lat'] as num).toDouble(),
      lng: (loc['lng'] as num).toDouble(),
    );
  }

  /// Reverse-geocode lat/lng → formatted address.
  static Future<String?> reverseGeocode(double lat, double lng) async {
    final res = await _client.functions.invoke(
      _fn,
      body: {'op': 'reverse', 'lat': lat, 'lng': lng},
    );
    final body = _readMap(res);
    if (body['error'] != null) {
      throw PlacesException(body['error'].toString());
    }
    final status = body['status'] as String?;
    if (status != 'OK') {
      if (status == 'ZERO_RESULTS') return null;
      throw PlacesException(
          'Reverse geocode $status. ${body['error_message'] ?? ''}');
    }
    final results = (body['results'] as List?) ?? const [];
    if (results.isEmpty) return null;
    return (results.first as Map)['formatted_address'] as String?;
  }
}

import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class UserLocationResult {
  final double latitude;
  final double longitude;
  final String label;

  UserLocationResult({
    required this.latitude,
    required this.longitude,
    required this.label,
  });
}

class LocationService {
  /// Request device GPS location with permission handling
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS on your device.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Please allow location access.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in your device settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Reverse geocode coordinates to get human readable address/area
  static Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=14&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'MandiIntelligenceApp/1.0 (contact@mandiintelligence.app)',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final place = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['suburb'] ??
              address['county'] ??
              address['state_district'];
          final state = address['state'];

          if (place != null && state != null) {
            return '$place, $state';
          } else if (place != null) {
            return place.toString();
          } else if (state != null) {
            return state.toString();
          }
        }
        if (data['display_name'] != null) {
          final parts = (data['display_name'] as String).split(',');
          if (parts.length >= 2) {
            return '${parts[0].trim()}, ${parts[1].trim()}';
          }
          return parts[0].trim();
        }
      }
    } catch (_) {
      // Fallback on network or timeout error
    }

    // Default coordinate representation
    return 'Location (${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})';
  }
}

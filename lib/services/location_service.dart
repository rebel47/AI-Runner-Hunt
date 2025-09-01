import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math';

class LocationService {
  LocationService._privateConstructor();
  static final LocationService instance = LocationService._privateConstructor();

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied. Please enable in settings.';
    }
    return true;
  }

  Future<Position> getCurrentLocation({LocationAccuracy accuracy = LocationAccuracy.high, int timeout = 10}) async {
    try {
      await requestPermission();
      return await Geolocator.getCurrentPosition(desiredAccuracy: accuracy).timeout(Duration(seconds: timeout));
    } catch (e) {
      throw 'Failed to get current location.';
    }
  }

  Stream<Position> watchPositionStream({LocationAccuracy accuracy = LocationAccuracy.high}) {
    return Geolocator.getPositionStream(locationSettings: LocationSettings(accuracy: accuracy));
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0; // meters
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  bool isWithinRange(double lat1, double lon1, double lat2, double lon2, double rangeMeters) {
    return calculateDistance(lat1, lon1, lat2, lon2) <= rangeMeters;
  }

  // Background location handling (placeholder)
  Future<void> enableBackgroundLocation() async {
    // Platform-specific implementation required
    // Use geolocator + background location plugins for iOS/Android
  }

  double _deg2rad(double deg) => deg * pi / 180.0;
}

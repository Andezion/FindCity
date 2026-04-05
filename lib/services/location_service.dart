import 'package:geolocator/geolocator.dart';

class LocationService {
  static Position? _lastPosition;

  static Position? get lastPosition => _lastPosition;

  static Future<LocationPermission> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermission.denied;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  static Future<Position?> getCurrentPosition() async {
    final permission = await requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      _lastPosition = pos;
      return pos;
    } catch (_) {
      return null;
    }
  }

  static bool get hasLocation => _lastPosition != null;
}

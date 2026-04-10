import 'dart:math';

class GeoUtils {
  static const double earthRadiusKm = 6371.0;

  static double calculateBearing(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    final dLng = (toLng - fromLng) * pi / 180;
    final lat1 = fromLat * pi / 180;
    final lat2 = toLat * pi / 180;

    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);

    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double bearingDifference(double b1, double b2) {
    double diff = ((b2 - b1) + 360) % 360;
    if (diff > 180) diff = 360 - diff;
    return diff;
  }
}

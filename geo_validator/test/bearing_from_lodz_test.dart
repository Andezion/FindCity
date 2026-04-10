import 'package:test/test.dart';
import 'package:geo_validator/geo_utils.dart';

const double LODZ_LAT = 51.7592;
const double LODZ_LNG = 19.4560;

const double TOLERANCE = 1.0;
const List<(String, double, double, double, String)> cities = [
  ('London', 51.5074, -0.1278, 277.9, 'nearly due West'),
  ('Paris', 48.8566, 2.3522, 261.8, 'W-SW'),
  ('Berlin', 52.5200, 13.4050, 284.0, 'WNW'),
  ('Madrid', 40.4168, -3.7038, 243.6, 'SW'),
  ('Rome', 41.9028, 12.4964, 208.4, 'SSW'),
  ('Kyiv', 50.4501, 30.5234, 96.3, 'E'),
  ('Warsaw', 52.2297, 21.0122, 63.2, 'ENE'),
  ('Vienna', 48.2082, 16.3738, 210.4, 'SSW'),
  ('Amsterdam', 52.3676, 4.9041, 279.6, 'W'),
  ('Prague', 50.0755, 14.4378, 243.9, 'SW'),
  ('Budapest', 47.4979, 19.0402, 185.5, 'S'),
  ('Barcelona', 41.3851, 2.1734, 234.9, 'SW'),
  ('Munich', 48.1351, 11.5820, 237.5, 'SW'),
  ('Bucharest', 44.4268, 26.1025, 148.2, 'SE'),
  ('Sofia', 42.6977, 23.3219, 162.4, 'SSE'),
  ('Athens', 37.9838, 23.7275, 166.1, 'SSE'),
  ('Stockholm', 59.3293, 18.0686, 354.6, 'N'),
  ('Oslo', 59.9139, 10.7522, 333.0, 'NNW'),
  ('Helsinki', 60.1699, 24.9384, 17.8, 'NNE'),
  ('Copenhagen', 55.6761, 12.5683, 316.6, 'NW'),
  ('Brussels', 50.8503, 4.3517, 270.4, 'W'),
  ('Lisbon', 38.7223, -9.1393, 248.0, 'WSW'),
  ('Dublin', 53.3498, -6.2603, 286.8, 'WNW'),
  ('Zurich', 47.3769, 8.5417, 242.5, 'WSW'),
  ('Minsk', 53.9045, 27.5615, 63.1, 'ENE'),
];

void main() {
  group('GeoUtils.calculateBearing — from Łódź (51.7592°N, 19.456°E)', () {
    for (final (name, lat, lng, expected, direction) in cities) {
      test('→ $name ($direction, expected ≈ ${expected.toStringAsFixed(1)}°)',
          () {
        final actual = GeoUtils.calculateBearing(LODZ_LAT, LODZ_LNG, lat, lng);
        expect(
          actual,
          closeTo(expected, TOLERANCE),
          reason: '$name: got ${actual.toStringAsFixed(2)}°, '
              'expected ${expected.toStringAsFixed(2)}° ± ${TOLERANCE}°',
        );
      });
    }
  });

  group('GeoUtils.calculateBearing — formula sanity checks', () {
    test('does not crash for same point (degenerate)', () {
      expect(
        () => GeoUtils.calculateBearing(LODZ_LAT, LODZ_LNG, LODZ_LAT, LODZ_LNG),
        returnsNormally,
      );
    });

    test('North Pole is due north (0°)', () {
      final b = GeoUtils.calculateBearing(LODZ_LAT, LODZ_LNG, 90.0, LODZ_LNG);
      expect(b, closeTo(0.0, TOLERANCE));
    });

    test('point due east gives bearing 90°', () {
      final b = GeoUtils.calculateBearing(0.0, 0.0, 0.0, 10.0);
      expect(b, closeTo(90.0, TOLERANCE));
    });

    test('point due west gives bearing 270°', () {
      final b = GeoUtils.calculateBearing(0.0, 10.0, 0.0, 0.0);
      expect(b, closeTo(270.0, TOLERANCE));
    });

    test('result is always in [0, 360)', () {
      for (final (_, lat, lng, _, _) in cities) {
        final b = GeoUtils.calculateBearing(LODZ_LAT, LODZ_LNG, lat, lng);
        expect(b, greaterThanOrEqualTo(0.0));
        expect(b, lessThan(360.0));
      }
    });

    test('bearingDifference is symmetric', () {
      expect(GeoUtils.bearingDifference(10, 350), closeTo(20.0, 0.001));
      expect(GeoUtils.bearingDifference(350, 10), closeTo(20.0, 0.001));
    });

    test('bearingDifference max is 180°', () {
      expect(GeoUtils.bearingDifference(0, 180), closeTo(180.0, 0.001));
      expect(GeoUtils.bearingDifference(90, 270), closeTo(180.0, 0.001));
    });

    test('bearingDifference handles wrap-around across 0/360', () {
      expect(GeoUtils.bearingDifference(359, 1), closeTo(2.0, 0.001));
      expect(GeoUtils.bearingDifference(1, 359), closeTo(2.0, 0.001));
    });
  });

  group('GeoUtils.calculateDistance — basic sanity', () {
    test('Łódź → Warsaw is ~120 km', () {
      final d =
          GeoUtils.calculateDistance(LODZ_LAT, LODZ_LNG, 52.2297, 21.0122);
      expect(d, closeTo(120.0, 10.0));
    });

    test('Łódź → London is ~1350 km', () {
      final d =
          GeoUtils.calculateDistance(LODZ_LAT, LODZ_LNG, 51.5074, -0.1278);
      expect(d, closeTo(1350.0, 30.0));
    });

    test('distance is symmetric', () {
      final d1 =
          GeoUtils.calculateDistance(LODZ_LAT, LODZ_LNG, 52.2297, 21.0122);
      final d2 =
          GeoUtils.calculateDistance(52.2297, 21.0122, LODZ_LAT, LODZ_LNG);
      expect(d1, closeTo(d2, 0.01));
    });

    test('distance to self is 0', () {
      final d =
          GeoUtils.calculateDistance(LODZ_LAT, LODZ_LNG, LODZ_LAT, LODZ_LNG);
      expect(d, closeTo(0.0, 0.001));
    });
  });
}

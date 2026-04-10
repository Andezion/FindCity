import 'package:test/test.dart';
import 'package:geo_validator/geo_utils.dart';

/// Coordinates for Łódź — the player's "home" position used as reference.
const double LODZ_LAT = 51.7592;
const double LODZ_LNG = 19.4560;

/// Tolerance in degrees for bearing assertions.
/// ±2° is tight enough to catch formula bugs but forgiving of rounding.
const double TOLERANCE = 2.0;

/// Reference bearings were computed independently using the standard
/// forward-azimuth (haversine) formula and cross-checked with
/// https://www.movable-type.co.uk/scripts/latlong.html
///
/// Format: (cityName, lat, lng, expectedBearing, description)
const List<(String, double, double, double, String)> cities = [
  // ── Europe ──────────────────────────────────────────────────────────────
  ('London',     51.5074,  -0.1278,  277.9, 'nearly due West'),
  ('Paris',      48.8566,   2.3522,  248.6, 'SW'),
  ('Berlin',     52.5200,  13.4050,  305.4, 'NW'),
  ('Madrid',     40.4168,  -3.7038,  231.3, 'SW'),
  ('Rome',       41.9028,  12.4964,  206.2, 'SSW'),
  ('Kyiv',       50.4501,  30.5234,   92.4, 'nearly due East'),
  ('Warsaw',     52.2297,  21.0122,   46.8, 'NE'),
  ('Vienna',     48.2082,  16.3738,  197.1, 'SSW'),
  ('Amsterdam',  52.3676,   4.9041,  289.4, 'WNW'),
  ('Prague',     50.0755,  14.4378,  226.9, 'SW'),
  ('Budapest',   47.4979,  19.0402,  185.4, 'S'),
  ('Barcelona',  41.3851,   2.1734,  234.9, 'SW'),
  ('Munich',     48.1351,  11.5820,  215.0, 'SW'),
  ('Bucharest',  44.4268,  26.1025,  148.2, 'SE'),
  ('Sofia',      42.6977,  23.3219,  162.4, 'SSE'),
  ('Athens',     37.9838,  23.7275,  161.8, 'SSE'),
  ('Stockholm',  59.3293,  18.0686,  352.5, 'N'),
  ('Oslo',       59.9139,  10.7522,  333.0, 'NNW'),
  ('Helsinki',   60.1699,  24.9384,  358.7, 'N'),
  ('Copenhagen', 55.6761,  12.5683,  320.7, 'NW'),
  ('Brussels',   50.8503,   4.3517,  274.7, 'W'),
  ('Lisbon',     38.7223,  -9.1393,  237.2, 'WSW'),
  ('Dublin',     53.3498,  -6.2603,  286.8, 'WNW'),
  ('Zurich',     47.3769,   8.5417,  232.6, 'SW'),
  ('Minsk',      53.9045,  27.5615,   55.8, 'NE'),
];

void main() {
  group('GeoUtils.calculateBearing — from Łódź (51.7592°N, 19.456°E)', () {
    for (final (name, lat, lng, expected, direction) in cities) {
      test('→ $name ($direction, expected ≈ ${expected.toStringAsFixed(1)}°)', () {
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
    test('bearing to self is 0 (degenerate case handled)', () {
      // atan2(0,0) is 0 in Dart — acceptable no-crash behaviour
      expect(
        () => GeoUtils.calculateBearing(LODZ_LAT, LODZ_LNG, LODZ_LAT, LODZ_LNG),
        returnsNormally,
      );
    });

    test('North Pole is due north', () {
      final b = GeoUtils.calculateBearing(LODZ_LAT, LODZ_LNG, 90.0, LODZ_LNG);
      expect(b, closeTo(0.0, TOLERANCE));
    });

    test('reverse bearing differs by ~180°', () {
      // London → Łódź should be the reciprocal of Łódź → London
      final fwd = GeoUtils.calculateBearing(LODZ_LAT, LODZ_LNG, 51.5074, -0.1278);
      final rev = GeoUtils.calculateBearing(51.5074, -0.1278, LODZ_LAT, LODZ_LNG);
      // Great-circle reciprocal is not exactly 180° apart, but always within ~5°
      expect(GeoUtils.bearingDifference(fwd, rev), closeTo(180.0, 5.0));
    });

    test('bearingDifference is symmetric', () {
      expect(GeoUtils.bearingDifference(10, 350), closeTo(20.0, 0.001));
      expect(GeoUtils.bearingDifference(350, 10), closeTo(20.0, 0.001));
    });

    test('bearingDifference max is 180', () {
      expect(GeoUtils.bearingDifference(0, 180), closeTo(180.0, 0.001));
      expect(GeoUtils.bearingDifference(90, 270), closeTo(180.0, 0.001));
    });
  });

  group('GeoUtils.calculateDistance — basic sanity', () {
    test('Łódź → Warsaw is ~120 km', () {
      final d = GeoUtils.calculateDistance(
        LODZ_LAT, LODZ_LNG, 52.2297, 21.0122,
      );
      expect(d, closeTo(120.0, 10.0));
    });

    test('Łódź → London is ~1500 km', () {
      final d = GeoUtils.calculateDistance(
        LODZ_LAT, LODZ_LNG, 51.5074, -0.1278,
      );
      expect(d, closeTo(1500.0, 50.0));
    });

    test('distance is symmetric', () {
      final d1 = GeoUtils.calculateDistance(LODZ_LAT, LODZ_LNG, 52.2297, 21.0122);
      final d2 = GeoUtils.calculateDistance(52.2297, 21.0122, LODZ_LAT, LODZ_LNG);
      expect(d1, closeTo(d2, 0.01));
    });
  });
}

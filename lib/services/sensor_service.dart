import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static StreamSubscription? _accelSub;
  static StreamSubscription? _magnetSub;

  static double _ax = 0, _ay = 0, _az = 9.8;
  static double _mx = 0, _my = 0, _mz = 0;
  static bool _hasMag = false;
  static bool _hasAccel = false;

  static double _smoothedHeading = 0;
  static bool _initialized = false;

  static final _ctrl = StreamController<double>.broadcast();

  static Stream<double> get headingStream => _ctrl.stream;

  static bool get isCompassAvailable => true;

  static void start() {
    _accelSub ??= accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 80),
    ).listen((e) {
      _ax = e.x;
      _ay = e.y;
      _az = e.z;
      _hasAccel = true;
      if (_hasMag) _compute();
    });

    _magnetSub ??= magnetometerEventStream(
      samplingPeriod: const Duration(milliseconds: 80),
    ).listen((e) {
      _mx = e.x;
      _my = e.y;
      _mz = e.z;
      _hasMag = true;
      if (_hasAccel) _compute();
    });
  }

  static void stop() {
    _accelSub?.cancel();
    _magnetSub?.cancel();
    _accelSub = null;
    _magnetSub = null;
    _initialized = false;
  }

  static void _compute() {
    final h = _calcHeading();
    if (h == null || _ctrl.isClosed) return;

    if (!_initialized) {
      _smoothedHeading = h;
      _initialized = true;
    } else {
      double diff = h - _smoothedHeading;
      if (diff > 180) diff -= 360;
      if (diff < -180) diff += 360;
      _smoothedHeading = (_smoothedHeading + diff * 0.18 + 360) % 360;
    }

    _ctrl.add(_smoothedHeading);
  }

  static double? _calcHeading() {
    final g = sqrt(_ax * _ax + _ay * _ay + _az * _az);
    if (g < 0.1) return null;

    final roll = atan2(_ay, _az);
    final pitch = atan2(-_ax, sqrt(_ay * _ay + _az * _az));

    final bxh = _mx * cos(pitch) +
        _my * sin(roll) * sin(pitch) +
        _mz * cos(roll) * sin(pitch);
    final byh = _my * cos(roll) - _mz * sin(roll);

    var heading = atan2(bxh, byh) * 180 / pi;
    if (heading < 0) heading += 360;
    return heading;
  }
}

import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

class SensorService {
  static StreamSubscription? _sub;

  static double _smoothedHeading = 0;
  static bool _initialized = false;

  static final _ctrl = StreamController<double>.broadcast();

  static Stream<double> get headingStream => _ctrl.stream;

  static bool get isCompassAvailable => FlutterCompass.events != null;

  static void start() {
    _sub ??= FlutterCompass.events!.listen((event) {
      final raw = event.heading;
      if (raw == null || _ctrl.isClosed) return;

      final h = (raw + 360) % 360;

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
    });
  }

  static void stop() {
    _sub?.cancel();
    _sub = null;
    _initialized = false;
  }
}

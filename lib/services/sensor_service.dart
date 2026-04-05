import 'package:flutter_compass/flutter_compass.dart';

class SensorService {
  static Stream<double?> get headingStream {
    return FlutterCompass.events!.map((event) => event.heading);
  }

  static bool get isCompassAvailable {
    return FlutterCompass.events != null;
  }
}

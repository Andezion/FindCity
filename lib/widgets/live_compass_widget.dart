import 'dart:math';
import 'package:flutter/material.dart';

/// A small live compass showing the phone's current heading during gameplay.
class LiveCompassWidget extends StatelessWidget {
  final double heading; // degrees, 0 = North
  final double size;

  const LiveCompassWidget({
    super.key,
    required this.heading,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LiveCompassPainter(heading: heading),
      ),
    );
  }
}

class _LiveCompassPainter extends CustomPainter {
  final double heading;

  _LiveCompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF1A2535),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF2E3F54)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // North needle (red)
    final northAngle = (-heading - 90) * pi / 180;
    final northTip = Offset(
      center.dx + radius * 0.7 * cos(northAngle),
      center.dy + radius * 0.7 * sin(northAngle),
    );
    final southTip = Offset(
      center.dx + radius * 0.4 * cos(northAngle + pi),
      center.dy + radius * 0.4 * sin(northAngle + pi),
    );

    // South half (white/gray)
    canvas.drawLine(
      center,
      southTip,
      Paint()
        ..color = const Color(0xFF607D8B)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    // North half (red)
    canvas.drawLine(
      center,
      northTip,
      Paint()
        ..color = const Color(0xFFF44336)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // N label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'С',
        style: TextStyle(
          color: Color(0xFFF44336),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        center.dx + (radius - 10) * cos(northAngle) - tp.width / 2,
        center.dy + (radius - 10) * sin(northAngle) - tp.height / 2,
      ),
    );

    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = Colors.white70);
  }

  @override
  bool shouldRepaint(covariant _LiveCompassPainter old) =>
      old.heading != heading;
}

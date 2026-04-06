import 'dart:math';
import 'package:flutter/material.dart';

class LiveCompassWidget extends StatelessWidget {
  final double heading;
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
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1A2535));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF2E3F54)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Tick marks (fixed rose)
    for (int i = 0; i < 36; i++) {
      final angle = (i * 10 - 90) * pi / 180;
      final isCardinal = i % 9 == 0;
      final tickLen = isCardinal ? 10.0 : 4.0;
      canvas.drawLine(
        Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)),
        Offset(center.dx + (radius - tickLen) * cos(angle),
            center.dy + (radius - tickLen) * sin(angle)),
        Paint()
          ..color = const Color(0xFF4A6080)
          ..strokeWidth = isCardinal ? 2 : 1,
      );
    }

    // Fixed cardinal labels
    _drawLabel(canvas, center, radius, 'С', 0);
    _drawLabel(canvas, center, radius, 'В', 90);
    _drawLabel(canvas, center, radius, 'Ю', 180);
    _drawLabel(canvas, center, radius, 'З', 270);

    // Single arrow: points where the top of the phone is aimed
    // heading=0°→up, heading=90°→right, etc.
    final arrowAngle = (heading - 90) * pi / 180;
    final arrowLen = radius * 0.68;
    final tailLen = radius * 0.22;

    final tip = Offset(
      center.dx + arrowLen * cos(arrowAngle),
      center.dy + arrowLen * sin(arrowAngle),
    );
    final tail = Offset(
      center.dx + tailLen * cos(arrowAngle + pi),
      center.dy + tailLen * sin(arrowAngle + pi),
    );

    // Shaft
    canvas.drawLine(
      tail,
      tip,
      Paint()
        ..color = const Color(0xFF00B4D8)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Arrowhead wings
    const headSize = 11.0;
    for (final side in [-1.0, 1.0]) {
      final wingAngle = arrowAngle + pi + side * 0.45;
      canvas.drawLine(
        tip,
        Offset(
          tip.dx + headSize * cos(wingAngle),
          tip.dy + headSize * sin(wingAngle),
        ),
        Paint()
          ..color = const Color(0xFF00B4D8)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }

    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = Colors.white70);
  }

  void _drawLabel(
      Canvas canvas, Offset center, double radius, String label, double bearing) {
    final angle = (bearing - 90) * pi / 180;
    final pos = Offset(
      center.dx + (radius - 14) * cos(angle),
      center.dy + (radius - 14) * sin(angle),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF90A4AE),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LiveCompassPainter old) =>
      old.heading != heading;
}

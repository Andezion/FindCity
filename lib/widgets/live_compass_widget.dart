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

    // Background circle
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1A2535));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF2E3F54)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Rotate canvas so the rose counter-rotates:
    // N always points to actual North in the room.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * pi / 180);
    canvas.translate(-center.dx, -center.dy);

    // Ticks (rotate with the rose)
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

    // Cardinal direction labels (rotate with the rose)
    _drawLabel(canvas, center, radius, 'С', 0, const Color(0xFFFF5252));
    _drawLabel(canvas, center, radius, 'В', 90, const Color(0xFF90A4AE));
    _drawLabel(canvas, center, radius, 'Ю', 180, const Color(0xFF90A4AE));
    _drawLabel(canvas, center, radius, 'З', 270, const Color(0xFF90A4AE));

    canvas.restore();

    // Fixed forward indicator — always at top, shows where phone is pointing.
    // Triangle pointing inward at 12 o'clock.
    final tipY = center.dy - radius + 6;
    final triPath = Path()
      ..moveTo(center.dx, tipY + 10)
      ..lineTo(center.dx - 6, tipY + 18)
      ..lineTo(center.dx + 6, tipY + 18)
      ..close();
    canvas.drawPath(triPath, Paint()..color = const Color(0xFF00B4D8));

    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = Colors.white70);
  }

  void _drawLabel(Canvas canvas, Offset center, double radius, String label,
      double bearing, Color color) {
    final angle = (bearing - 90) * pi / 180;
    final pos = Offset(
      center.dx + (radius - 14) * cos(angle),
      center.dy + (radius - 14) * sin(angle),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
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

import 'dart:math';
import 'package:flutter/material.dart';

class CompassResultWidget extends StatelessWidget {
  final double userBearing;
  final double correctBearing;
  final double tolerance;
  final bool isCorrect;

  const CompassResultWidget({
    super.key,
    required this.userBearing,
    required this.correctBearing,
    required this.tolerance,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: CustomPaint(
        painter: _CompassPainter(
          userBearing: userBearing,
          correctBearing: correctBearing,
          tolerance: tolerance,
          isCorrect: isCorrect,
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double userBearing;
  final double correctBearing;
  final double tolerance;
  final bool isCorrect;

  _CompassPainter({
    required this.userBearing,
    required this.correctBearing,
    required this.tolerance,
    required this.isCorrect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-userBearing * pi / 180);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF1E2A3A),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF2E3F54)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (int i = 0; i < 36; i++) {
      final angle = (i * 10 - 90) * pi / 180;
      final isCardinal = i % 9 == 0;
      final tickLen = isCardinal ? 12.0 : 6.0;
      final p1 = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - tickLen) * cos(angle),
        center.dy + (radius - tickLen) * sin(angle),
      );
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = const Color(0xFF4A6080)
          ..strokeWidth = isCardinal ? 2 : 1,
      );
    }

    final arcColor = isCorrect
        ? const Color(0xFF4CAF50).withValues(alpha: 0.35)
        : const Color(0xFFFF5252).withValues(alpha: 0.25);
    final arcStartAngle = (correctBearing - tolerance - 90) * pi / 180;
    final arcSweep = 2 * tolerance * pi / 180;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      arcStartAngle,
      arcSweep,
      true,
      Paint()..color = arcColor,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      arcStartAngle,
      arcSweep,
      false,
      Paint()
        ..color = isCorrect
            ? const Color(0xFF4CAF50).withValues(alpha: 0.6)
            : const Color(0xFFFF5252).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _drawArrow(
      canvas,
      center,
      correctBearing,
      radius * 0.82,
      isCorrect ? const Color(0xFF4CAF50) : const Color(0xFF69F0AE),
      strokeWidth: 3.5,
      arrowSize: 12,
    );

    _drawArrow(
      canvas,
      center,
      userBearing,
      radius * 0.65,
      const Color(0xFF2196F3),
      strokeWidth: 2.5,
      arrowSize: 10,
    );

    _drawCardinalLabel(canvas, center, radius, 'С', 0);
    _drawCardinalLabel(canvas, center, radius, 'В', 90);
    _drawCardinalLabel(canvas, center, radius, 'Ю', 180);
    _drawCardinalLabel(canvas, center, radius, 'З', 270);

    canvas.drawCircle(
      center,
      5,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    canvas.restore();

    _drawLegend(canvas, size);
  }

  void _drawArrow(
    Canvas canvas,
    Offset center,
    double bearing,
    double length,
    Color color, {
    double strokeWidth = 3,
    double arrowSize = 10,
  }) {
    final angle = (bearing - 90) * pi / 180;
    final tip = Offset(
      center.dx + length * cos(angle),
      center.dy + length * sin(angle),
    );

    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    final leftAngle = angle - pi * 0.7;
    final rightAngle = angle + pi * 0.7;
    final left = Offset(
      tip.dx + arrowSize * 0.6 * cos(leftAngle),
      tip.dy + arrowSize * 0.6 * sin(leftAngle),
    );
    final right = Offset(
      tip.dx + arrowSize * 0.6 * cos(rightAngle),
      tip.dy + arrowSize * 0.6 * sin(rightAngle),
    );
    canvas.drawLine(
        tip,
        left,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth);
    canvas.drawLine(
        tip,
        right,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth);
  }

  void _drawCardinalLabel(
    Canvas canvas,
    Offset center,
    double radius,
    String label,
    double bearing,
  ) {
    final angle = (bearing - 90) * pi / 180;
    final pos = Offset(
      center.dx + (radius + 14) * cos(angle),
      center.dy + (radius + 14) * sin(angle),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF90A4AE),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2),
    );
  }

  void _drawLegend(Canvas canvas, Size size) {
    const dotRadius = 5.0;
    const spacing = 6.0;
    const textStyle = TextStyle(color: Color(0xFF90A4AE), fontSize: 11);

    canvas.drawCircle(
      Offset(16, size.height - 28),
      dotRadius,
      Paint()..color = const Color(0xFF69F0AE),
    );
    _paintText(
        canvas, 'Верное направление', Offset(26, size.height - 34), textStyle);

    canvas.drawCircle(
      Offset(16, size.height - 28 + dotRadius * 2 + spacing),
      dotRadius,
      Paint()..color = const Color(0xFF2196F3),
    );
    _paintText(
      canvas,
      'Ваше направление',
      Offset(26, size.height - 34 + dotRadius * 2 + spacing),
      textStyle,
    );
  }

  void _paintText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) {
    return old.userBearing != userBearing ||
        old.correctBearing != correctBearing ||
        old.isCorrect != isCorrect;
  }
}

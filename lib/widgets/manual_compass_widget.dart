import 'dart:math';
import 'package:flutter/material.dart';

class ManualCompassWidget extends StatefulWidget {
  final double initialHeading;
  final double size;
  final ValueChanged<double> onChanged;

  const ManualCompassWidget({
    super.key,
    required this.initialHeading,
    required this.onChanged,
    this.size = 200,
  });

  @override
  State<ManualCompassWidget> createState() => _ManualCompassWidgetState();
}

class _ManualCompassWidgetState extends State<ManualCompassWidget> {
  late double _heading;

  @override
  void initState() {
    super.initState();
    _heading = widget.initialHeading;
  }

  void _updateFromOffset(Offset localPos) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final delta = localPos - center;
    if (delta.distance < 12) return;

    // canvas angle → compass bearing
    final angle = atan2(delta.dy, delta.dx) * 180 / pi;
    final heading = (angle + 90 + 360) % 360;
    setState(() => _heading = heading);
    widget.onChanged(_heading);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) => _updateFromOffset(d.localPosition),
      onPanStart: (d) => _updateFromOffset(d.localPosition),
      onTapDown: (d) => _updateFromOffset(d.localPosition),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _ManualCompassPainter(heading: _heading),
        ),
      ),
    );
  }
}

class _ManualCompassPainter extends CustomPainter {
  final double heading;

  _ManualCompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1A2535));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF2E3F54)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Tick marks
    for (int i = 0; i < 36; i++) {
      final angle = (i * 10 - 90) * pi / 180;
      final isCardinal = i % 9 == 0;
      final tickLen = isCardinal ? 14.0 : 6.0;
      canvas.drawLine(
        Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)),
        Offset(center.dx + (radius - tickLen) * cos(angle),
            center.dy + (radius - tickLen) * sin(angle)),
        Paint()
          ..color = isCardinal ? const Color(0xFF607D8B) : const Color(0xFF3A5068)
          ..strokeWidth = isCardinal ? 2 : 1,
      );
    }

    // Cardinal labels
    _drawLabel(canvas, center, radius, 'С', 0);
    _drawLabel(canvas, center, radius, 'В', 90);
    _drawLabel(canvas, center, radius, 'Ю', 180);
    _drawLabel(canvas, center, radius, 'З', 270);

    // Drag hint ring
    canvas.drawCircle(
      center,
      radius * 0.85,
      Paint()
        ..color = const Color(0xFF00B4D8).withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20,
    );

    // Arrow
    final arrowAngle = (heading - 90) * pi / 180;
    final arrowLen = radius * 0.72;
    final tailLen = radius * 0.22;

    final tip = Offset(
      center.dx + arrowLen * cos(arrowAngle),
      center.dy + arrowLen * sin(arrowAngle),
    );
    final tail = Offset(
      center.dx + tailLen * cos(arrowAngle + pi),
      center.dy + tailLen * sin(arrowAngle + pi),
    );

    canvas.drawLine(
      tail,
      tip,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Arrowhead
    const headSize = 14.0;
    for (final side in [-1.0, 1.0]) {
      final wingAngle = arrowAngle + pi + side * 0.45;
      canvas.drawLine(
        tip,
        Offset(
          tip.dx + headSize * cos(wingAngle),
          tip.dy + headSize * sin(wingAngle),
        ),
        Paint()
          ..color = const Color(0xFF00E5FF)
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Drag circle at tip
    canvas.drawCircle(
      tip,
      10,
      Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      tip,
      10,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Center dot
    canvas.drawCircle(center, 5, Paint()..color = Colors.white70);
  }

  void _drawLabel(
      Canvas canvas, Offset center, double radius, String label, double bearing) {
    final angle = (bearing - 90) * pi / 180;
    final pos = Offset(
      center.dx + (radius - 18) * cos(angle),
      center.dy + (radius - 18) * sin(angle),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF90A4AE),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ManualCompassPainter old) =>
      old.heading != heading;
}

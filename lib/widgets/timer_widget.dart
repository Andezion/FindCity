import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback onComplete;
  final bool running;

  const TimerWidget({
    super.key,
    required this.seconds,
    required this.onComplete,
    this.running = true,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    );

    if (widget.running) {
      _controller.forward();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_remaining > 0) _timer.cancel();
    super.dispose();
  }

  Color get _timerColor {
    final ratio = _remaining / widget.seconds;
    if (ratio > 0.5) return const Color(0xFF4CAF50);
    if (ratio > 0.25) return const Color(0xFFFF9800);
    return const Color(0xFFFF5252);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CircularProgressIndicator(
              value: 1.0 - _controller.value,
              strokeWidth: 5,
              backgroundColor: const Color(0xFF2E3F54),
              valueColor: AlwaysStoppedAnimation(_timerColor),
            ),
          ),
          Text(
            '$_remaining',
            style: TextStyle(
              color: _timerColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

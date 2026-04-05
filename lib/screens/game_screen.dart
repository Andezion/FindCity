import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_session.dart';
import '../models/game_settings.dart';
import '../services/sensor_service.dart';
import '../services/location_service.dart';
import '../utils/geo_utils.dart';
import '../widgets/compass_result_widget.dart';
import '../widgets/live_compass_widget.dart';
import '../widgets/timer_widget.dart';
import 'score_screen.dart';

enum _Phase { pointing, result }

class GameScreen extends StatefulWidget {
  final GameSession session;

  const GameScreen({super.key, required this.session});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.pointing;
  double _heading = 0.0;
  StreamSubscription<double?>? _compassSub;
  CardResult? _lastResult;
  bool _compassAvailable = false;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  int _timerKey = 0;

  @override
  void initState() {
    super.initState();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();

    _compassAvailable = SensorService.isCompassAvailable;
    if (_compassAvailable) {
      _compassSub = SensorService.headingStream.listen((h) {
        if (h != null && _phase == _Phase.pointing) {
          setState(() => _heading = h);
        }
      });
    }
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_phase == _Phase.result) return;
    _submitAnswer();
  }

  void _submitAnswer() {
    final pos = LocationService.lastPosition;
    final city = widget.session.currentCity;

    double correctBearing = 0;
    double distance = 0;

    if (pos != null) {
      correctBearing = GeoUtils.calculateBearing(
        pos.latitude,
        pos.longitude,
        city.lat,
        city.lng,
      );
      distance = GeoUtils.calculateDistance(
        pos.latitude,
        pos.longitude,
        city.lat,
        city.lng,
      );
    }

    final tolerance = widget.session.settings.difficulty.tolerance;
    final diff = GeoUtils.bearingDifference(_heading, correctBearing);
    final isCorrect = diff <= tolerance;

    final result = CardResult(
      city: city,
      userBearing: _heading,
      correctBearing: correctBearing,
      distanceKm: distance,
      isCorrect: isCorrect,
      teamIndex: widget.session.settings.mode == GameMode.team
          ? widget.session.currentTeamIndex
          : null,
    );

    widget.session.results.add(result);

    setState(() {
      _phase = _Phase.result;
      _lastResult = result;
    });
  }

  void _next() {
    final session = widget.session;
    final settings = session.settings;

    if (settings.mode == GameMode.team) {
      final teamCardsDone = session.results
          .where((r) => r.teamIndex == session.currentTeamIndex)
          .length;
      if (teamCardsDone >= settings.cardCount) {
        session.currentTeamIndex++;
      }
    }

    if (session.isLastCard ||
        (settings.mode == GameMode.team &&
            session.currentTeamIndex >= settings.teamCount)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ScoreScreen(session: session)),
      );
      return;
    }

    session.currentIndex++;
    setState(() {
      _phase = _Phase.pointing;
      _timerKey++;
    });
    _slideCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final settings = session.settings;
    final city = session.currentCity;
    final total =
        settings.mode == GameMode.infinite ? '∞' : '${session.cities.length}';
    final current = session.currentIndex + 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showExitDialog(),
                    child: const Icon(Icons.close, color: Color(0xFF607D8B)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (settings.mode == GameMode.team)
                          Text(
                            session.teamName.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF00B4D8),
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        LinearProgressIndicator(
                          value: session.currentIndex / session.cities.length,
                          backgroundColor: const Color(0xFF1E2D3D),
                          valueColor:
                              const AlwaysStoppedAnimation(Color(0xFF00B4D8)),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$current / $total',
                    style:
                        const TextStyle(color: Color(0xFF607D8B), fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _phase == _Phase.pointing
                  ? _buildPointingPhase(city, settings)
                  : _buildResultPhase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointingPhase(city, GameSettings settings) {
    return SlideTransition(
      position: _slideAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E2D3D), Color(0xFF0D1B2A)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2E3F54)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4D8).withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    city.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${city.nameEn} • ${city.country}',
                    style: const TextStyle(
                      color: Color(0xFF607D8B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (_compassAvailable) ...[
              LiveCompassWidget(heading: _heading, size: 140),
              const SizedBox(height: 12),
              Text(
                '${_heading.toStringAsFixed(0)}°',
                style: const TextStyle(
                  color: Color(0xFF00B4D8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ] else
              const Text(
                'Компас недоступен на устройстве',
                style: TextStyle(color: Color(0xFFFF9800)),
              ),
            const SizedBox(height: 8),
            const Text(
              'Направь телефон в сторону города',
              style: TextStyle(color: Color(0xFF90A4AE), fontSize: 13),
            ),
            const Spacer(),
            Row(
              children: [
                if (settings.timePerCard != null) ...[
                  TimerWidget(
                    key: ValueKey(_timerKey),
                    seconds: settings.timePerCard!,
                    onComplete: _submitAnswer,
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _confirm,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'Подтвердить',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPhase() {
    final result = _lastResult!;
    final diff =
        GeoUtils.bearingDifference(result.userBearing, result.correctBearing);
    final tolerance = widget.session.settings.difficulty.tolerance;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: result.isCorrect
                  ? const Color(0xFF1B3A27)
                  : const Color(0xFF3A1B1B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: result.isCorrect
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF5252),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  result.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: result.isCorrect
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF5252),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.isCorrect ? 'Правильно!' : 'Мимо!',
                        style: TextStyle(
                          color: result.isCorrect
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF5252),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Погрешность: ${diff.toStringAsFixed(1)}° (допустимо ±${tolerance.toInt()}°)',
                        style: const TextStyle(
                            color: Color(0xFF90A4AE), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CompassResultWidget(
            userBearing: result.userBearing,
            correctBearing: result.correctBearing,
            tolerance: tolerance,
            isCorrect: result.isCorrect,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D3D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2E3F54)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        result.city.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B2A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        GeoUtils.formatDistance(result.distanceKm),
                        style: const TextStyle(
                          color: Color(0xFF00B4D8),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.city.country} • ${(result.city.population / 1e6).toStringAsFixed(1)} млн чел.',
                  style:
                      const TextStyle(color: Color(0xFF607D8B), fontSize: 13),
                ),
                const SizedBox(height: 10),
                Text(
                  result.city.description,
                  style: const TextStyle(
                      color: Color(0xFFB0BEC5), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _infoChip(Icons.navigation,
                        'Верное: ${result.correctBearing.toStringAsFixed(0)}°'),
                    const SizedBox(width: 8),
                    _infoChip(Icons.near_me,
                        'Ваше: ${result.userBearing.toStringAsFixed(0)}°'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                widget.session.isLastCard ? 'Итоги' : 'Следующий город',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4D8),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF607D8B)),
            const SizedBox(width: 4),
            Text(text,
                style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 12)),
          ],
        ),
      );

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Выйти из игры?', style: TextStyle(color: Colors.white)),
        content: const Text('Прогресс не сохранится.',
            style: TextStyle(color: Color(0xFF90A4AE))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена',
                style: TextStyle(color: Color(0xFF607D8B))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child:
                const Text('Выйти', style: TextStyle(color: Color(0xFFFF5252))),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/game_session.dart';
import '../models/game_settings.dart';
import '../utils/geo_utils.dart';
import 'home_screen.dart';

class ScoreScreen extends StatelessWidget {
  final GameSession session;

  const ScoreScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final isTeam = session.settings.mode == GameMode.team;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.emoji_events_rounded,
                size: 64, color: Color(0xFFFFD700)),
            const SizedBox(height: 12),
            const Text(
              'ИГРА ОКОНЧЕНА',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: isTeam ? _teamScores() : _soloScore(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text(
                        'На главную',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _soloScore() {
    final total = session.results.length;
    final correct = session.totalScore;
    final pct = total > 0 ? (correct / total * 100).round() : 0;

    return Column(
      children: [
        _scoreBig(correct, total, pct),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'КАРТОЧКИ',
            style: TextStyle(
              color: Color(0xFF607D8B),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: session.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _resultTile(session.results[i]),
          ),
        ),
      ],
    );
  }

  Widget _teamScores() {
    final scores = session.teamScores;
    final maxScore = scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        ...List.generate(scores.length, (i) {
          final isWinner = scores[i] == maxScore && maxScore > 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isWinner
                    ? const Color(0xFF1B2E1B)
                    : const Color(0xFF1E2D3D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isWinner
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF2E3F54),
                  width: isWinner ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (isWinner)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.emoji_events,
                          color: Color(0xFFFFD700), size: 24),
                    ),
                  Text(
                    'Команда ${i + 1}',
                    style: TextStyle(
                      color: isWinner
                          ? const Color(0xFFFFD700)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${scores[i]} / ${session.settings.cardCount}',
                    style: TextStyle(
                      color: isWinner
                          ? const Color(0xFFFFD700)
                          : const Color(0xFF00B4D8),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'ВСЕ ОТВЕТЫ',
            style: TextStyle(
              color: Color(0xFF607D8B),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: session.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) => _resultTile(
              session.results[i],
              showTeam: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _scoreBig(int correct, int total, int pct) {
    final color = pct >= 70
        ? const Color(0xFF4CAF50)
        : pct >= 40
            ? const Color(0xFFFF9800)
            : const Color(0xFFFF5252);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D3D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E3F54)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statCol('$correct', 'верно', const Color(0xFF4CAF50)),
          Container(width: 1, height: 40, color: const Color(0xFF2E3F54)),
          _statCol('${total - correct}', 'мимо', const Color(0xFFFF5252)),
          Container(width: 1, height: 40, color: const Color(0xFF2E3F54)),
          _statCol('$pct%', 'точность', color),
        ],
      ),
    );
  }

  Widget _statCol(String value, String label, Color color) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(color: Color(0xFF607D8B), fontSize: 12)),
        ],
      );

  Widget _resultTile(CardResult r, {bool showTeam = false}) {
    final diff =
        GeoUtils.bearingDifference(r.userBearing, r.correctBearing);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161E2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: r.isCorrect
              ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
              : const Color(0xFFFF5252).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            r.isCorrect ? Icons.check_circle : Icons.cancel,
            color: r.isCorrect
                ? const Color(0xFF4CAF50)
                : const Color(0xFFFF5252),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.city.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text(
                  r.city.country,
                  style: const TextStyle(
                      color: Color(0xFF607D8B), fontSize: 12),
                ),
              ],
            ),
          ),
          if (showTeam && r.teamIndex != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'К${r.teamIndex! + 1}',
                style: const TextStyle(
                    color: Color(0xFF00B4D8), fontSize: 12),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${diff.toStringAsFixed(0)}°',
                style: TextStyle(
                  color: r.isCorrect
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF5252),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                GeoUtils.formatDistance(r.distanceKm),
                style: const TextStyle(
                    color: Color(0xFF607D8B), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


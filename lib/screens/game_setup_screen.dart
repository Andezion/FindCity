import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/groq_config.dart';
import '../models/game_settings.dart';
import '../models/game_session.dart';
import '../services/cities_service.dart';
import '../services/groq_service.dart';
import '../services/location_service.dart';
import 'game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  final GameSettings settings;

  const GameSetupScreen({super.key, required this.settings});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  late GameSettings _settings;
  final _customCountController = TextEditingController(text: '10');
  bool _loading = false;
  String? _loadingStatus;
  String? _error;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void dispose() {
    _customCountController.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    setState(() {
      _loading = true;
      _loadingStatus = 'Получаю геолокацию...';
      _error = null;
    });

    final pos = await LocationService.getCurrentPosition();
    if (pos == null && mounted) {
      setState(() {
        _loading = false;
        _loadingStatus = null;
        _error =
            'Не удалось получить геолокацию.\nПроверь разрешения приложения.';
      });
      return;
    }

    int cardCount = _settings.cardCount;
    if (_settings.mode == GameMode.custom) {
      cardCount = int.tryParse(_customCountController.text) ?? 10;
    } else if (_settings.mode == GameMode.fixed10) {
      cardCount = 10;
    } else if (_settings.mode == GameMode.infinite) {
      cardCount = 9999;
    } else if (_settings.mode == GameMode.team) {
      cardCount = _settings.cardCount;
    }

    final fetchCount = _settings.mode == GameMode.infinite ? 50 : cardCount;

    var cities = <dynamic>[];

    if (GroqConfig.isConfigured) {
      setState(() => _loadingStatus = 'Загружаю города через AI...');
      try {
        cities = await GroqService.fetchCities(
          region: _settings.region,
          count: fetchCount,
        );
      } catch (_) {
        // fallback to static data
        cities = CitiesService.selectCities(
          _settings.region,
          count: _settings.mode == GameMode.infinite ? null : cardCount,
        );
      }
    } else {
      cities = CitiesService.selectCities(
        _settings.region,
        count: _settings.mode == GameMode.infinite ? null : cardCount,
      );
    }

    if (!mounted) return;

    final session = GameSession(
      settings: _settings.copyWith(cardCount: cardCount),
      cities: List.from(cities),
    );

    setState(() {
      _loading = false;
      _loadingStatus = null;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(session: session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_settings.region.label),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Режим игры'),
              const SizedBox(height: 8),
              _modeSelector(),
              if (_settings.mode == GameMode.custom) ...[
                const SizedBox(height: 12),
                _customCountField(),
              ],
              if (_settings.mode == GameMode.team) ...[
                const SizedBox(height: 12),
                _teamSettings(),
              ],
              const SizedBox(height: 24),
              _section('Время на карточку'),
              const SizedBox(height: 8),
              _timeSelector(),
              const SizedBox(height: 24),
              _section('Сложность (допустимая погрешность)'),
              const SizedBox(height: 8),
              _difficultySelector(),
              const SizedBox(height: 32),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A1515),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFFF5252)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFFFF5252)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _startGame,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    _loading ? (_loadingStatus ?? 'Загрузка...') : 'Начать игру',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4D8),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF607D8B),
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _modeSelector() {
    final modes = [
      (GameMode.solo, 'Одиночная', Icons.person),
      (GameMode.team, 'Команды', Icons.group),
      (GameMode.fixed10, '10 карт', Icons.filter_1),
      (GameMode.infinite, 'Бесконечная', Icons.all_inclusive),
      (GameMode.custom, 'Своё число', Icons.tune),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: modes.map((m) {
        final selected = _settings.mode == m.$1;
        return GestureDetector(
          onTap: () =>
              setState(() => _settings = _settings.copyWith(mode: m.$1)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color:
                  selected ? const Color(0xFF00B4D8) : const Color(0xFF1E2D3D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? const Color(0xFF00B4D8)
                    : const Color(0xFF2E3F54),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(m.$3,
                    size: 16,
                    color: selected ? Colors.black : const Color(0xFF90A4AE)),
                const SizedBox(width: 6),
                Text(
                  m.$2,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _customCountField() => Row(
        children: [
          const Text('Количество карточек:',
              style: TextStyle(color: Color(0xFF90A4AE))),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _customCountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E2D3D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E3F54)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E3F54)),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _teamSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Команд:', style: TextStyle(color: Color(0xFF90A4AE))),
            const SizedBox(width: 12),
            _counter(
              value: _settings.teamCount,
              min: 2,
              max: 6,
              onChanged: (v) =>
                  setState(() => _settings = _settings.copyWith(teamCount: v)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Карт на команду:',
                style: TextStyle(color: Color(0xFF90A4AE))),
            const SizedBox(width: 12),
            _counter(
              value: _settings.cardCount,
              min: 1,
              max: 20,
              onChanged: (v) =>
                  setState(() => _settings = _settings.copyWith(cardCount: v)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _counter({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        _iconBtn(Icons.remove, () {
          if (value > min) onChanged(value - 1);
        }),
        const SizedBox(width: 8),
        Text('$value',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        _iconBtn(Icons.add, () {
          if (value < max) onChanged(value + 1);
        }),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2D3D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E3F54)),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF00B4D8)),
        ),
      );

  Widget _timeSelector() {
    final options = [
      (10, '10 с'),
      (20, '20 с'),
      (30, '30 с'),
      (60, '60 с'),
      (null, '∞'),
    ];

    return Row(
      children: options.map((o) {
        final selected = _settings.timePerCard == o.$1;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() {
              _settings = o.$1 == null
                  ? _settings.copyWith(clearTime: true)
                  : _settings.copyWith(timePerCard: o.$1);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 54,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF00B4D8)
                    : const Color(0xFF1E2D3D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF00B4D8)
                      : const Color(0xFF2E3F54),
                ),
              ),
              child: Center(
                child: Text(
                  o.$2,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _difficultySelector() {
    return Row(
      children: Difficulty.values.map((d) {
        final selected = _settings.difficulty == d;
        final colors = {
          Difficulty.easy: const Color(0xFF4CAF50),
          Difficulty.medium: const Color(0xFFFF9800),
          Difficulty.hard: const Color(0xFFFF5252),
        };
        final color = colors[d]!;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () =>
                setState(() => _settings = _settings.copyWith(difficulty: d)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.2)
                    : const Color(0xFF1E2D3D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? color : const Color(0xFF2E3F54),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    d.label,
                    style: TextStyle(
                      color: selected ? color : const Color(0xFF90A4AE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '±${d.tolerance.toInt()}°',
                    style: TextStyle(
                      color: selected
                          ? color.withValues(alpha: 0.7)
                          : const Color(0xFF607D8B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

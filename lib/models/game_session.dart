import 'city.dart';
import 'game_settings.dart';

class CardResult {
  final City city;
  final double userBearing;
  final double correctBearing;
  final double distanceKm;
  final bool isCorrect;
  final int? teamIndex;

  const CardResult({
    required this.city,
    required this.userBearing,
    required this.correctBearing,
    required this.distanceKm,
    required this.isCorrect,
    this.teamIndex,
  });
}

class GameSession {
  final GameSettings settings;
  final List<City> cities;
  int currentIndex;
  final List<CardResult> results;
  int currentTeamIndex;

  GameSession({
    required this.settings,
    required this.cities,
    this.currentIndex = 0,
    List<CardResult>? results,
    this.currentTeamIndex = 0,
  }) : results = results ?? [];

  bool get isFinished {
    if (settings.mode == GameMode.infinite) return false;
    return currentIndex >= cities.length;
  }

  bool get isLastCard => currentIndex >= cities.length - 1;

  City get currentCity => cities[currentIndex];

  int get totalScore => results.where((r) => r.isCorrect).length;

  List<int> get teamScores {
    return List.generate(
      settings.teamCount,
      (i) => results.where((r) => r.teamIndex == i && r.isCorrect).length,
    );
  }

  String get teamName => 'Команда ${currentTeamIndex + 1}';

  // Cards played by current team
  int get currentTeamCardCount =>
      results.where((r) => r.teamIndex == currentTeamIndex).length;
}

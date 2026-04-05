enum GameRegion {
  world,
  europe,
  asia,
  northAmerica,
  southAmerica,
  africa,
  oceania,
}

extension GameRegionExtension on GameRegion {
  String get label {
    switch (this) {
      case GameRegion.world:
        return 'Весь мир';
      case GameRegion.europe:
        return 'Европа';
      case GameRegion.asia:
        return 'Азия';
      case GameRegion.northAmerica:
        return 'Северная Америка';
      case GameRegion.southAmerica:
        return 'Южная Америка';
      case GameRegion.africa:
        return 'Африка';
      case GameRegion.oceania:
        return 'Океания';
    }
  }

  String get emoji {
    switch (this) {
      case GameRegion.world:
        return '🌍';
      case GameRegion.europe:
        return '🏰';
      case GameRegion.asia:
        return '🏯';
      case GameRegion.northAmerica:
        return '🗽';
      case GameRegion.southAmerica:
        return '🌎';
      case GameRegion.africa:
        return '🦁';
      case GameRegion.oceania:
        return '🦘';
    }
  }

  String get key {
    switch (this) {
      case GameRegion.world:
        return 'world';
      case GameRegion.europe:
        return 'europe';
      case GameRegion.asia:
        return 'asia';
      case GameRegion.northAmerica:
        return 'north_america';
      case GameRegion.southAmerica:
        return 'south_america';
      case GameRegion.africa:
        return 'africa';
      case GameRegion.oceania:
        return 'oceania';
    }
  }
}

enum GameMode {
  solo,
  team,
  fixed10,
  infinite,
  custom,
}

extension GameModeExtension on GameMode {
  String get label {
    switch (this) {
      case GameMode.solo:
        return 'Одиночная';
      case GameMode.team:
        return 'Командная';
      case GameMode.fixed10:
        return '10 карточек';
      case GameMode.infinite:
        return 'Бесконечная';
      case GameMode.custom:
        return 'Своё число';
    }
  }
}

enum Difficulty {
  easy,
  medium,
  hard,
}

extension DifficultyExtension on Difficulty {
  double get tolerance {
    switch (this) {
      case Difficulty.easy:
        return 30.0;
      case Difficulty.medium:
        return 20.0;
      case Difficulty.hard:
        return 10.0;
    }
  }

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Лёгкий';
      case Difficulty.medium:
        return 'Средний';
      case Difficulty.hard:
        return 'Сложный';
    }
  }
}

class GameSettings {
  final GameRegion region;
  final GameMode mode;
  final int cardCount;
  final int teamCount;
  final int? timePerCard;
  final Difficulty difficulty;

  const GameSettings({
    required this.region,
    this.mode = GameMode.solo,
    this.cardCount = 10,
    this.teamCount = 2,
    this.timePerCard = 30,
    this.difficulty = Difficulty.medium,
  });

  GameSettings copyWith({
    GameRegion? region,
    GameMode? mode,
    int? cardCount,
    int? teamCount,
    int? timePerCard,
    bool clearTime = false,
    Difficulty? difficulty,
  }) {
    return GameSettings(
      region: region ?? this.region,
      mode: mode ?? this.mode,
      cardCount: cardCount ?? this.cardCount,
      teamCount: teamCount ?? this.teamCount,
      timePerCard: clearTime ? null : (timePerCard ?? this.timePerCard),
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

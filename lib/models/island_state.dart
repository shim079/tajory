class IslandState {
  final int level;
  final int points;
  final String theme;
  final List<String> unlockedFeatures;
  final DateTime lastUpdated;

  IslandState({
    this.level = 1,
    this.points = 0,
    this.theme = 'island',
    List<String>? unlockedFeatures,
    DateTime? lastUpdated,
  })  : unlockedFeatures = unlockedFeatures ?? ['basic_island'],
        lastUpdated = lastUpdated ?? DateTime.now();

  int get pointsToNextLevel => level * 100;
  double get levelProgress =>
      pointsToNextLevel > 0
          ? (points / pointsToNextLevel).clamp(0.0, 1.0)
          : 0.0;

  String get description {
    switch (level) {
      case 1: return 'A small sandy island just emerged';
      case 2: return 'Grass and small trees are growing';
      case 3: return 'A freshwater spring has appeared';
      case 4: return 'Wildflowers bloom across the island';
      case 5: return 'A cozy shelter has been built';
      case 6: return 'Palm trees sway in the breeze';
      case 7: return 'A bridge connects to a smaller isle';
      case 8: return 'The island now has a small garden';
      case 9: return 'A lighthouse guides the way';
      case 10: return 'Your island paradise is complete!';
      default: return 'A thriving island ecosystem';
    }
  }

  IslandState evolve(int pointsEarned) {
    final newPoints = points + pointsEarned;
    final newLevel = level + (newPoints ~/ pointsToNextLevel);
    final remainingPoints = newPoints % pointsToNextLevel;

    final newFeatures = List<String>.from(unlockedFeatures);
    if (newLevel > level) {
      for (var i = level + 1; i <= newLevel; i++) {
        newFeatures.add('feature_level_$i');
      }
    }

    return IslandState(
      level: newLevel,
      points: newLevel > level ? remainingPoints : newPoints,
      unlockedFeatures: newFeatures,
    );
  }

  Map<String, dynamic> toMap() => {
    'level': level,
    'points': points,
    'theme': theme,
    'unlockedFeatures': unlockedFeatures,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory IslandState.fromMap(Map<String, dynamic> map) {
    return IslandState(
      level: map['level'] as int? ?? 1,
      points: map['points'] as int? ?? 0,
      theme: map['theme'] as String? ?? 'island',
      unlockedFeatures: (map['unlockedFeatures'] as List<dynamic>?)
              ?.cast<String>() ??
          ['basic_island'],
      lastUpdated: map['lastUpdated'] is String
          ? DateTime.parse(map['lastUpdated'] as String)
          : (map['lastUpdated'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}

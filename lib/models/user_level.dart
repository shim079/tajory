class UserLevel {
  final int level;
  final String name;
  final int minXp;
  final int maxXp;

  const UserLevel({
    required this.level,
    required this.name,
    required this.minXp,
    required this.maxXp,
  });
}

const List<UserLevel> levels = [
  UserLevel(level: 1, name: 'المستوى الاول', minXp: 0, maxXp: 499),
  UserLevel(level: 2, name: 'المستوى الثاني', minXp: 500, maxXp: 1499),
  UserLevel(level: 3, name: 'المستوى الثالث', minXp: 1500, maxXp: 2999),
  UserLevel(level: 4, name: 'المستوى الرابع', minXp: 3000, maxXp: 5999),
  UserLevel(level: 5, name: 'المستوى الخامس', minXp: 6000, maxXp: 9999),
  UserLevel(level: 6, name: 'المستوى السادس', minXp: 10000, maxXp: 999999),
];

class UserLevelResult {
  final int level;
  final String name;
  final int currentXP;
  final int minXp;
  final int maxXp;
  final double progress;

  const UserLevelResult({
    required this.level,
    required this.name,
    required this.currentXP,
    required this.minXp,
    required this.maxXp,
    required this.progress,
  });
}

UserLevelResult calculateUserLevel(int totalXP) {
  for (final l in levels) {
    if (totalXP <= l.maxXp) {
      final range = l.maxXp - l.minXp + 1;
      final current = totalXP - l.minXp;
      final progress = (current / range).clamp(0.0, 1.0);

      return UserLevelResult(
        level: l.level,
        name: l.name,
        currentXP: totalXP,
        minXp: l.minXp,
        maxXp: l.maxXp,
        progress: progress,
      );
    }
  }

  final last = levels.last;
  return UserLevelResult(
    level: last.level,
    name: last.name,
    currentXP: totalXP,
    minXp: last.minXp,
    maxXp: last.maxXp,
    progress: 1.0,
  );
}

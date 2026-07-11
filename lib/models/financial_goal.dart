import 'dart:math';

class FinancialGoal {
  final String? id;
  final String title;
  final double target;
  final double saved;
  final DateTime createdAt;
  final DateTime? deadline;
  final DateTime? completedAt;
  final bool isCompleted;

  FinancialGoal({
    this.id,
    required this.title,
    required this.target,
    this.saved = 0,
    DateTime? createdAt,
    this.deadline,
    this.completedAt,
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progressPercent =>
      target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;

  double get remaining => (target - saved).clamp(0.0, double.infinity);

  int? get daysRemaining {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  String? get estimatedCompletionDate {
    if (saved <= 0 || target <= 0) return null;
    final monthlySave = saved / max(1, DateTime.now().difference(createdAt).inDays / 30);
    if (monthlySave <= 0) return null;
    final monthsLeft = (remaining / monthlySave).ceil();
    if (monthsLeft <= 0) return null;
    return DateTime.now()
        .add(Duration(days: monthsLeft * 30))
        .toIso8601String()
        .split('T')[0];
  }

  int get milestonesReached {
    int count = 0;
    if (progressPercent >= 0.25) count++;
    if (progressPercent >= 0.50) count++;
    if (progressPercent >= 0.75) count++;
    if (isCompleted) count++;
    return count;
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'target': target,
    'saved': saved,
    'createdAt': createdAt.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory FinancialGoal.fromMap(Map<String, dynamic> map, {String? id}) {
    return FinancialGoal(
      id: id,
      title: map['title'] as String,
      target: (map['target'] as num).toDouble(),
      saved: (map['saved'] as num?)?.toDouble() ?? 0,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      deadline: map['deadline'] != null
          ? map['deadline'] is String
              ? DateTime.parse(map['deadline'] as String)
              : (map['deadline'] as dynamic)?.toDate()
          : null,
      completedAt: map['completedAt'] != null
          ? map['completedAt'] is String
              ? DateTime.parse(map['completedAt'] as String)
              : (map['completedAt'] as dynamic)?.toDate()
          : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}

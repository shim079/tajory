enum HabitType { saving, budgeting, reducing }

class Habit {
  final String? id;
  final HabitType type;
  final String name;
  final String description;
  final String iconAsset;
  final bool active;
  final DateTime createdAt;

  Habit({
    this.id,
    required this.type,
    required this.name,
    required this.description,
    this.iconAsset = 'savings',
    this.active = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'name': name,
    'description': description,
    'iconAsset': iconAsset,
    'active': active,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Habit.fromMap(Map<String, dynamic> map, {String? id}) {
    return Habit(
      id: id,
      type: HabitType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => HabitType.saving,
      ),
      name: map['name'] as String,
      description: map['description'] as String,
      iconAsset: map['iconAsset'] as String? ?? 'savings',
      active: map['active'] as bool? ?? true,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  static List<Habit> get defaults => [
    Habit(
      type: HabitType.saving,
      name: 'Saving',
      description: 'Set aside a portion of your income regularly',
      iconAsset: 'savings',
    ),
    Habit(
      type: HabitType.budgeting,
      name: 'Budgeting',
      description: 'Plan and track your monthly spending',
      iconAsset: 'budgeting',
    ),
    Habit(
      type: HabitType.reducing,
      name: 'Reducing Expenses',
      description: 'Cut down on unnecessary spending',
      iconAsset: 'reducing',
    ),
  ];
}

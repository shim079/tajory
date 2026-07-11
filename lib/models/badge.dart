class Badge {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final String category;
  final int requiredCount;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    this.iconAsset = 'star',
    required this.category,
    this.requiredCount = 1,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'iconAsset': iconAsset,
    'category': category,
    'requiredCount': requiredCount,
  };

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      iconAsset: map['iconAsset'] as String? ?? 'star',
      category: map['category'] as String,
      requiredCount: map['requiredCount'] as int? ?? 1,
    );
  }

  static List<Badge> get all => [
    Badge(
      id: 'first_expense',
      title: 'First Expense',
      description: 'Track your first expense',
      category: 'expenses',
      requiredCount: 1,
    ),
    Badge(
      id: 'first_goal',
      title: 'Goal Setter',
      description: 'Create your first financial goal',
      category: 'goals',
      requiredCount: 1,
    ),
    Badge(
      id: 'goal_complete_1',
      title: 'Goal Crusher',
      description: 'Complete your first financial goal',
      category: 'goals',
      requiredCount: 1,
    ),
    Badge(
      id: 'goal_complete_3',
      title: 'Goal Master',
      description: 'Complete 3 financial goals',
      category: 'goals',
      requiredCount: 3,
    ),
    Badge(
      id: 'expenses_10',
      title: 'Track Record',
      description: 'Log 10 expenses',
      category: 'expenses',
      requiredCount: 10,
    ),
    Badge(
      id: 'expenses_50',
      title: 'Expense Expert',
      description: 'Log 50 expenses',
      category: 'expenses',
      requiredCount: 50,
    ),
    Badge(
      id: 'savings_100',
      title: 'First Savings',
      description: 'Save \$100 total',
      category: 'savings',
      requiredCount: 100,
      iconAsset: 'savings',
    ),
    Badge(
      id: 'savings_1000',
      title: 'Savings Star',
      description: 'Save \$1,000 total',
      category: 'savings',
      requiredCount: 1000,
      iconAsset: 'savings',
    ),
    Badge(
      id: 'island_5',
      title: 'Explorer',
      description: 'Reach island level 5',
      category: 'island',
      requiredCount: 5,
    ),
    Badge(
      id: 'island_10',
      title: 'Island Legend',
      description: 'Reach island level 10',
      category: 'island',
      requiredCount: 10,
    ),
    Badge(
      id: 'habit_7',
      title: 'Habit Starter',
      description: 'Maintain a habit for 7 days',
      category: 'habits',
      requiredCount: 7,
    ),
    Badge(
      id: 'habit_30',
      title: 'Habit Hero',
      description: 'Maintain a habit for 30 days',
      category: 'habits',
      requiredCount: 30,
    ),
  ];
}

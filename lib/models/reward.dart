class Reward {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final DateTime unlockedAt;
  final bool isNew;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    this.iconAsset = 'star',
    DateTime? unlockedAt,
    this.isNew = true,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'iconAsset': iconAsset,
    'unlockedAt': unlockedAt.toIso8601String(),
    'isNew': isNew,
  };

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      iconAsset: map['iconAsset'] as String? ?? 'star',
      unlockedAt: map['unlockedAt'] is String
          ? DateTime.parse(map['unlockedAt'] as String)
          : (map['unlockedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isNew: map['isNew'] as bool? ?? false,
    );
  }
}

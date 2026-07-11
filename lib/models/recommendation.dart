class Recommendation {
  final String id;
  final String message;
  final String category;
  final int priority;
  final DateTime createdAt;
  final bool isRead;

  Recommendation({
    required this.id,
    required this.message,
    required this.category,
    this.priority = 0,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'message': message,
    'category': category,
    'priority': priority,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'] as String,
      message: map['message'] as String,
      category: map['category'] as String,
      priority: map['priority'] as int? ?? 0,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }
}

class ActivityLog {
  final String? id;
  final String action;
  final String description;
  final int xpEarned;
  final DateTime timestamp;

  ActivityLog({
    this.id,
    required this.action,
    required this.description,
    this.xpEarned = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'action': action,
    'description': description,
    'xpEarned': xpEarned,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ActivityLog.fromMap(Map<String, dynamic> map, {String? id}) {
    return ActivityLog(
      id: id,
      action: map['action'] as String? ?? '',
      description: map['description'] as String? ?? '',
      xpEarned: (map['xpEarned'] as num?)?.toInt() ?? 0,
      timestamp: map['timestamp'] is String
          ? DateTime.parse(map['timestamp'] as String)
          : (map['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}

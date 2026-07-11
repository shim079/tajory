class SavingsRecord {
  final String? id;
  final double amount;
  final String? notes;
  final DateTime date;
  final String? goalId;

  SavingsRecord({
    this.id,
    required this.amount,
    this.notes,
    DateTime? date,
    this.goalId,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'notes': notes ?? '',
    'date': date.toIso8601String(),
    'goalId': goalId ?? '',
  };

  factory SavingsRecord.fromMap(Map<String, dynamic> map, {String? id}) {
    return SavingsRecord(
      id: id,
      amount: (map['amount'] as num).toDouble(),
      notes: map['notes'] as String?,
      date: map['date'] is String
          ? DateTime.parse(map['date'] as String)
          : (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
      goalId: map['goalId'] as String?,
    );
  }
}

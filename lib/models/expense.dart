class Expense {
  final String? id;
  final double amount;
  final String category;
  final String description;
  final String source;
  final DateTime date;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    this.description = '',
    this.source = 'manual',
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'category': category,
    'description': description,
    'source': source,
    'date': date.toIso8601String(),
  };

  factory Expense.fromMap(Map<String, dynamic> map, {String? id}) {
    return Expense(
      id: id,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String? ?? 'Other',
      description: map['description'] as String? ?? '',
      source: map['source'] as String? ?? 'manual',
      date: map['date'] is String
          ? DateTime.parse(map['date'] as String)
          : (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  static const List<String> standardCategories = [
    'Food',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills',
    'Healthcare',
    'Education',
    'Other',
  ];

  static String classify(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('food') || lower.contains('eat') || lower.contains('restaurant') ||
        lower.contains('grocery') || lower.contains('dinner') || lower.contains('lunch') ||
        lower.contains('breakfast') || lower.contains('meal') || lower.contains('snack') ||
        lower.contains('coffee') || lower.contains('cafe')) {
      return 'Food';
    }
    if (lower.contains('transport') || lower.contains('gas') || lower.contains('fuel') ||
        lower.contains('bus') || lower.contains('train') || lower.contains('uber') ||
        lower.contains('taxi') || lower.contains('metro') || lower.contains('parking')) {
      return 'Transportation';
    }
    if (lower.contains('shop') || lower.contains('clothes') || lower.contains('amazon') ||
        lower.contains('online') || lower.contains('retail') || lower.contains('store') ||
        lower.contains('mall') || lower.contains('purchase')) {
      return 'Shopping';
    }
    if (lower.contains('entertain') || lower.contains('movie') || lower.contains('netflix') ||
        lower.contains('spotify') || lower.contains('game') || lower.contains('concert') ||
        lower.contains('cinema') || lower.contains('subscription')) {
      return 'Entertainment';
    }
    if (lower.contains('bill') || lower.contains('electric') || lower.contains('water') ||
        lower.contains('internet') || lower.contains('phone') || lower.contains('utility') ||
        lower.contains('rent') || lower.contains('mortgage') || lower.contains('insurance')) {
      return 'Bills';
    }
    if (lower.contains('health') || lower.contains('doctor') || lower.contains('hospital') ||
        lower.contains('pharmacy') || lower.contains('medicine') || lower.contains('dentist') ||
        lower.contains('medical') || lower.contains('clinic') || lower.contains('eye')) {
      return 'Healthcare';
    }
    if (lower.contains('education') || lower.contains('school') || lower.contains('university') ||
        lower.contains('course') || lower.contains('class') || lower.contains('tutor') ||
        lower.contains('book') || lower.contains('library') || lower.contains('training')) {
      return 'Education';
    }
    return 'Other';
  }

  static String standardizeCategory(String category) {
    final classified = classify(category);
    for (final std in standardCategories) {
      if (classified == std) return std;
    }
    return classified;
  }
}

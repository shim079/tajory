import 'dart:math';
import '../models/expense.dart';
import '../models/financial_goal.dart';
import '../models/recommendation.dart';

class InsightService {
  static const _templates = {
    'saving': [
      'Try automating a fixed transfer to savings each payday.',
      'You could save more by reviewing unused subscriptions.',
      'Consider the 50/30/20 rule: 50% needs, 30% wants, 20% savings.',
      'Round up your daily purchases and save the spare change.',
      'Set a specific savings goal to stay motivated.',
      'Review your insurance plans — you might find better rates.',
    ],
    'budgeting': [
      'Track every expense for a week to identify spending leaks.',
      'Use cash envelopes for categories you tend to overspend on.',
      'Plan your meals weekly to reduce food waste and costs.',
      'Review your utility bills and consider switching providers.',
      'Allocate a fixed amount for entertainment each month.',
      'Try a no-spend weekend once a month.',
    ],
    'reducing': [
      'Cook at home 3 more times per week instead of dining out.',
      'Cancel subscriptions you haven\'t used in 30 days.',
      'Buy generic brands instead of name brands.',
      'Walk or bike for short trips instead of driving.',
      'Borrow books from the library instead of buying them.',
      'Wait 48 hours before making any non-essential purchase.',
    ],
  };

  List<Recommendation> generateRecommendations({
    required double income,
    required double expenses,
    required String habitType,
    required List<FinancialGoal> goals,
  }) {
    final recommendations = <Recommendation>[];
    final now = DateTime.now();

    if (income <= 0) {
      recommendations.add(Recommendation(
        id: 'setup_income',
        message: 'Set your monthly income to get personalized recommendations.',
        category: 'general',
        priority: 10,
        createdAt: now,
      ));
      return recommendations;
    }

    final savingRate = income > 0
        ? ((income - expenses) / income) * 100
        : 0.0;

    if (savingRate < 10) {
      recommendations.add(Recommendation(
        id: 'low_savings_alert',
        message:
            'Your saving rate is ${savingRate.toStringAsFixed(1)}%. Aim for at least 20%.',
        category: 'saving',
        priority: 9,
        createdAt: now,
      ));
    } else if (savingRate >= 20) {
      recommendations.add(Recommendation(
        id: 'good_savings',
        message:
            'Great job saving ${savingRate.toStringAsFixed(1)}% of your income! Keep it up.',
        category: 'saving',
        priority: 3,
        createdAt: now,
      ));
    }

    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    if (activeGoals.isEmpty) {
      recommendations.add(Recommendation(
        id: 'set_goal',
        message:
            'Set a financial goal to stay focused and motivated on your journey.',
        category: 'goals',
        priority: 8,
        createdAt: now,
      ));
    } else {
      for (final goal in activeGoals) {
        if (goal.progressPercent < 0.25) {
          final remaining = goal.remaining.toStringAsFixed(0);
          recommendations.add(Recommendation(
            id: 'goal_progress_${goal.id}',
            message:
                'You\'re \$$remaining away from "${goal.title}". Small daily steps add up!',
            category: 'goals',
            priority: 6,
            createdAt: now,
          ));
        } else if (goal.progressPercent >= 0.75) {
          recommendations.add(Recommendation(
            id: 'goal_close_${goal.id}',
            message:
                'Almost there! You\'re ${(goal.progressPercent * 100).toStringAsFixed(0)}% to "${goal.title}".',
            category: 'goals',
            priority: 7,
            createdAt: now,
          ));
        }
      }
    }

    final habitTemplates = _templates[habitType] ?? _templates['saving']!;
    final rng = Random(now.millisecondsSinceEpoch);
    final template =
        habitTemplates[rng.nextInt(habitTemplates.length)];

    recommendations.add(Recommendation(
      id: 'habit_tip_$habitType',
      message: template,
      category: habitType,
      priority: 5,
      createdAt: now,
    ));

    if (expenses > income * 0.8) {
      recommendations.add(Recommendation(
        id: 'high_expenses_alert',
        message:
            'Your expenses are ${((expenses / income) * 100).toStringAsFixed(0)}% of income. Consider cutting back.',
        category: 'reducing',
        priority: 9,
        createdAt: now,
      ));
    }

    return recommendations;
  }

  /// Detect repeated behaviors from expense history.
  List<Recommendation> detectRepeatedBehaviors({
    required double income,
    required double expenses,
    required List<Expense> recentExpenses,
    required Map<String, double> categoryTotals,
  }) {
    final recommendations = <Recommendation>[];
    final now = DateTime.now();

    if (recentExpenses.length < 3) return recommendations;

    // ── Frequent purchase detection ──
    final categoryCount = <String, int>{};
    for (final exp in recentExpenses) {
      categoryCount[exp.category] = (categoryCount[exp.category] ?? 0) + 1;
    }

    for (final entry in categoryCount.entries) {
      if (entry.value >= 5 && categoryTotals[entry.key] != null) {
        final total = categoryTotals[entry.key]!;
        recommendations.add(Recommendation(
          id: 'frequent_${entry.key}',
          message:
              'You\'ve made ${entry.value} purchases in "${entry.key}" recently (total: \$${total.toStringAsFixed(0)}). Consider setting a monthly limit.',
          category: 'reducing',
          priority: 7,
          createdAt: now,
        ));
      }
    }

    // ── Overspending category detection ──
    if (expenses > 0) {
      for (final entry in categoryTotals.entries) {
        final percent = (entry.value / expenses) * 100;
        if (percent > 40) {
          recommendations.add(Recommendation(
            id: 'overspend_${entry.key}',
            message:
                '"${entry.key}" is ${percent.toStringAsFixed(0)}% of your spending. Try to keep each category under 30%.',
            category: 'budgeting',
            priority: 8,
            createdAt: now,
          ));
        }
      }
    }

    // ── Consistent saving detection ──
    if (income > 0) {
      final savingRate = ((income - expenses) / income) * 100;
      if (savingRate >= 20) {
        recommendations.add(Recommendation(
          id: 'consistent_saving',
          message:
              'You\'re consistently saving ${savingRate.toStringAsFixed(0)}% of income. Excellent discipline!',
          category: 'saving',
          priority: 2,
          createdAt: now,
        ));
      }

      // ── Missed saving opportunities ──
      if (recentExpenses.length >= 5) {
        final nonEssentialTotal = categoryTotals.entries
            .where((e) => ['Entertainment', 'Shopping', 'Food'].contains(e.key))
            .fold<double>(0, (sum, e) => sum + e.value);

        if (nonEssentialTotal > income * 0.3) {
          recommendations.add(Recommendation(
            id: 'missed_savings',
            message:
                'Non-essential spending (Food, Shopping, Entertainment) is \$${nonEssentialTotal.toStringAsFixed(0)}. Reducing this by 20% could save \$${(nonEssentialTotal * 0.2).toStringAsFixed(0)}.',
            category: 'saving',
            priority: 7,
            createdAt: now,
          ));
        }
      }
    }

    return recommendations;
  }

  String generateInsight(double income, double expenses) {
    if (income == 0) {
      return 'Please set your income to get insights.';
    }

    final ratio = (expenses / income) * 100;

    if (ratio < 40) {
      return "Excellent! You're saving a lot — your island is thriving!";
    } else if (ratio < 70) {
      return 'Good control. Try reducing small expenses to grow your island.';
    } else if (ratio < 90) {
      return 'Warning: High spending detected. Your island progress may slow.';
    } else {
      return 'Critical: You\'re spending almost everything! Time to budget.';
    }
  }

  String detectSpendingPattern(Map<String, double> categoryTotals, double total) {
    if (total == 0) return 'No expenses tracked yet. Start adding expenses!';

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) return 'Spending distribution looks balanced.';

    final topCategory = entries.first;
    final percent = (topCategory.value / total) * 100;

    if (percent > 40) {
      return '${topCategory.key} spending is ${percent.toStringAsFixed(0)}% of total — consider diversifying.';
    }
    return 'Spending distribution looks balanced.';
  }
}

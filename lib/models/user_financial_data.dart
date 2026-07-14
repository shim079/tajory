import '../models/expense.dart';
import '../models/financial_goal.dart';

class UserFinancialData {
  final double income;
  final double totalExpenses;
  final double totalSavings;
  final Map<String, double> categoryTotals;
  final List<FinancialGoal> goals;
  final List<Expense> recentExpenses;
  final double? previousMonthExpenses;
  final double? previousMonthSavings;

  const UserFinancialData({
    required this.income,
    required this.totalExpenses,
    required this.totalSavings,
    required this.categoryTotals,
    required this.goals,
    required this.recentExpenses,
    this.previousMonthExpenses,
    this.previousMonthSavings,
  });

  double get savingRate =>
      income > 0 ? ((income - totalExpenses) / income * 100).clamp(0, 100) : 0.0;

  double get spendingPercent =>
      income > 0 ? (totalExpenses / income * 100).clamp(0, 100) : 0.0;

  List<FinancialGoal> get activeGoals =>
      goals.where((g) => !g.isCompleted).toList();

  List<FinancialGoal> get completedGoals =>
      goals.where((g) => g.isCompleted).toList();
}

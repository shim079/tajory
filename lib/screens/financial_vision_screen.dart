import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';
import '../models/recommendation.dart';
import '../services/firestore_service.dart';
import '../services/insight_service.dart';
import '../widgets/advisor_card.dart';
import '../widgets/period_selector.dart';
import '../widgets/month_navigator.dart';
import '../widgets/donut_chart.dart';

class FinancialVisionScreen extends StatefulWidget {
  const FinancialVisionScreen({super.key});

  @override
  State<FinancialVisionScreen> createState() => _FinancialVisionScreenState();
}

class _FinancialVisionScreenState extends State<FinancialVisionScreen> {
  final firestoreService = FirestoreService();
  final insightService = InsightService();

  double income = 0;
  double totalExpenses = 0;
  Map<String, double> categoryTotals = {};
  List<Recommendation> recommendations = [];
  bool isLoading = true;

  Period selectedPeriod = Period.monthly;
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Expense> allExpenses = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final profile = await firestoreService.getUserProfile(user.uid);
      final expenses = await firestoreService.getExpenses(user.uid);
      final recs = await firestoreService.getRecommendations(user.uid);

      final inc = (profile?['income'] as num?)?.toDouble() ?? 0;

      if (recs.isEmpty && inc > 0) {
        final goals = await firestoreService.getGoals(user.uid);
        final allExp = await firestoreService.calculateTotalExpenses(user.uid);
        final habit = await firestoreService.getActiveHabit(user.uid);
        final newRecs = insightService.generateRecommendations(
          income: inc,
          expenses: allExp,
          habitType: habit?.type.name ?? 'saving',
          goals: goals,
        );
        await firestoreService.saveRecommendations(
          uid: user.uid,
          recommendations: newRecs,
        );
      }

      if (!mounted) return;
      setState(() {
        income = inc;
        allExpenses = expenses;
        totalExpenses = expenses.fold<double>(0, (s, e) => s + e.amount);
        categoryTotals = _groupByCategory(expenses);
        recommendations = recs;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Map<String, double> _groupByCategory(List<Expense> expenses) {
    final map = <String, double>{};
    for (final exp in expenses) {
      map[exp.category] = (map[exp.category] ?? 0) + exp.amount;
    }
    return map;
  }

  List<Expense> _filteredExpenses() {
    final now = DateTime.now();
    return allExpenses.where((exp) {
      switch (selectedPeriod) {
        case Period.daily:
          return exp.date.year == now.year &&
              exp.date.month == now.month &&
              exp.date.day == now.day;
        case Period.weekly:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 7));
          return exp.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              exp.date.isBefore(weekEnd);
        case Period.monthly:
          return exp.date.year == currentMonth.year &&
              exp.date.month == currentMonth.month;
      }
    }).toList();
  }

  Map<String, double> get filteredCategoryTotals =>
      _groupByCategory(_filteredExpenses());

  double get filteredTotalExpenses =>
      _filteredExpenses().fold<double>(0, (s, e) => s + e.amount);

  void goToPreviousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void goToNextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredCats = filteredCategoryTotals;
    final filteredTotal = filteredTotalExpenses;
    final savings = income - totalExpenses;
    final savingRate = income > 0 ? ((savings / income) * 100).clamp(0, 100) : 0.0;
    final insight = insightService.generateInsight(income, totalExpenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Vision'),
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Period Selector ──
              PeriodSelector(
                selected: selectedPeriod,
                onChanged: (p) => setState(() => selectedPeriod = p),
              ),
              const SizedBox(height: 12),

              // ── Month Navigator ──
              if (selectedPeriod == Period.monthly) ...[
                MonthNavigator(
                  currentMonth: currentMonth,
                  onPrevious: goToPreviousMonth,
                  onNext: goToNextMonth,
                ),
                const SizedBox(height: 4),
              ],

              // ── Summary Cards ──
              SizedBox(
                height: 110,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      _summaryCard(
                        theme: theme,
                        label: 'Income',
                        value: '\$${income.toStringAsFixed(0)}',
                        icon: Icons.trending_up_rounded,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      _summaryCard(
                        theme: theme,
                        label: 'Expenses',
                        value: '\$${totalExpenses.toStringAsFixed(0)}',
                        icon: Icons.trending_down_rounded,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      _summaryCard(
                        theme: theme,
                        label: 'Savings',
                        value: '\$${savings.toStringAsFixed(0)}',
                        icon: Icons.savings_rounded,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      _summaryCard(
                        theme: theme,
                        label: 'Saving Rate',
                        value: '${savingRate.toStringAsFixed(1)}%',
                        icon: Icons.pie_chart_rounded,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Donut Chart ──
              if (filteredTotal > 0)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Spending Distribution',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DonutChart(data: filteredCats, size: 180, strokeWidth: 36),
                        const SizedBox(height: 12),
                        Text(
                          'Total: \$${filteredTotal.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.pie_chart_outline_rounded,
                              size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'No expenses in this period',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // ── Advisor Insight ──
              AdvisorCard(message: insight),
              const SizedBox(height: 16),

              // ── Recommendations ──
              if (recommendations.isNotEmpty) ...[
                Text(
                  'Recommendations',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...recommendations.take(3).map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              _iconForCategory(rec.category),
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            rec.message,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                    )),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: SizedBox(
        width: 130,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'saving':
        return Icons.savings_rounded;
      case 'goals':
        return Icons.flag_rounded;
      case 'reducing':
        return Icons.shopping_cart_rounded;
      case 'budgeting':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }
}

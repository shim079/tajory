import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';
import '../models/financial_advice.dart';
import '../models/recommendation.dart';
import '../models/user_financial_data.dart';
import '../services/firestore_service.dart';
import '../services/financial_advisor_service.dart';
import '../services/insight_service.dart';
import '../widgets/behavior_card.dart';
import '../widgets/statistics_filter.dart';
import '../widgets/month_selector.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/advisor_recommendation_card.dart';
import 'add_expense_screen.dart';


class FinancialVisionScreen extends StatefulWidget {
  const FinancialVisionScreen({super.key});

  @override
  State<FinancialVisionScreen> createState() => _FinancialVisionScreenState();
}

class _FinancialVisionScreenState extends State<FinancialVisionScreen> {
  final firestoreService = FirestoreService();
  final insightService = InsightService();
  final advisorService = FinancialAdvisorService();

  double income = 0;
  double totalExpenses = 0;
  double totalSavings = 0;
  Map<String, double> categoryTotals = {};
  List<Recommendation> recommendations = [];
  List<FinancialAdvice> financialAdvice = [];
  bool isLoading = true;

  int _selectedFilterIndex = 2; // شهري default
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

      final inc = (profile?['income'] as num?)?.toDouble() ?? 0;
      final goals = await firestoreService.getGoals(user.uid);
      final allExp = await firestoreService.calculateTotalExpenses(user.uid);

      final catTotals = _groupByCategory(expenses);

      // Calculate previous month data
      final now = DateTime.now();
      final prevMonth = DateTime(now.year, now.month - 1);
      final prevMonthExpenses = expenses
          .where((e) => e.date.year == prevMonth.year && e.date.month == prevMonth.month)
          .fold<double>(0, (s, e) => s + e.amount);

      // Assemble user data for advisor
      final savings = inc - allExp;
      final prevMonthSavings = prevMonthExpenses > 0 ? (inc - prevMonthExpenses) : null;

      final userData = UserFinancialData(
        income: inc,
        totalExpenses: allExp,
        totalSavings: savings,
        categoryTotals: catTotals,
        goals: goals,
        recentExpenses: expenses.take(30).toList(),
        previousMonthExpenses: prevMonthExpenses > 0 ? prevMonthExpenses : null,
        previousMonthSavings: prevMonthSavings,
      );

      // Generate personalized advice
      final advice = advisorService.generateAdvice(userData);

      // Generate recommendations for behavior cards
      final habit = await firestoreService.getActiveHabit(user.uid);
      final newRecs = insightService.generateRecommendations(
        income: inc,
        expenses: allExp,
        habitType: habit?.type.name ?? 'saving',
        goals: goals,
        allExpenses: expenses,
        categoryTotals: catTotals,
        previousMonthExpenses: prevMonthExpenses > 0 ? prevMonthExpenses : null,
      );

      if (expenses.length >= 3) {
        final behaviorRecs = insightService.detectRepeatedBehaviors(
          income: inc,
          expenses: allExp,
          recentExpenses: expenses.take(30).toList(),
          categoryTotals: catTotals,
        );
        final existingIds = newRecs.map((r) => r.id).toSet();
        for (final rec in behaviorRecs) {
          if (!existingIds.contains(rec.id)) {
            newRecs.add(rec);
          }
        }

        // Goal-aware behavioral recommendations
        final goalRecs = insightService.detectGoalBehaviors(
          income: inc,
          expenses: allExp,
          goals: goals,
          categoryTotals: catTotals,
        );
        for (final rec in goalRecs) {
          if (!existingIds.contains(rec.id)) {
            newRecs.add(rec);
          }
        }
      }

      newRecs.sort((a, b) => b.priority.compareTo(a.priority));

      await firestoreService.saveRecommendations(
        uid: user.uid,
        recommendations: newRecs,
      );

      if (!mounted) return;
      setState(() {
        income = inc;
        allExpenses = expenses;
        totalExpenses = allExp;
        totalSavings = savings;
        categoryTotals = catTotals;
        recommendations = newRecs;
        financialAdvice = advice;
        isLoading = false;
      });

      if (advice.isNotEmpty) {
        firestoreService.updateUserProfile(
          uid: user.uid,
          data: {
            'adviceTitle': advice.first.title,
            'adviceMessage': advice.first.message,
          },
        );
      }
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
      switch (_selectedFilterIndex) {
        case 0: // يومي
          return exp.date.year == now.year &&
              exp.date.month == now.month &&
              exp.date.day == now.day;
        case 1: // أسبوعي
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 7));
          return exp.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              exp.date.isBefore(weekEnd);
        case 2: // شهري
          return exp.date.year == currentMonth.year &&
              exp.date.month == currentMonth.month;
        default:
          return true;
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

  // ── Recommendation → Behavior card mapping ──

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
      case 'spending':
        return Icons.trending_up_rounded;
      case 'trends':
        return Icons.show_chart_rounded;
      case 'category':
        return Icons.pie_chart_rounded;
      case 'weekly':
        return Icons.date_range_rounded;
      case 'achievements':
        return Icons.emoji_events_rounded;
      case 'unusual':
        return Icons.warning_amber_rounded;
      case 'general':
        return Icons.info_outline_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }

  String _arabicTitleForCategory(String category) {
    switch (category) {
      case 'saving':
        return 'ادخار';
      case 'goals':
        return 'اهداف';
      case 'reducing':
        return 'تقليل';
      case 'budgeting':
        return 'ميزانية';
      case 'spending':
        return 'تحليل الصرف';
      case 'trends':
        return 'اتجاهات';
      case 'category':
        return 'تحليل الفئات';
      case 'weekly':
        return 'check-in أسبوعي';
      case 'achievements':
        return 'انجازات';
      case 'unusual':
        return 'نشاط غير عادي';
      case 'general':
        return 'توصية';
      default:
        return 'نصيحة';
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'saving':
        return const Color(0xFF2E7D32);
      case 'goals':
        return const Color(0xFFD9A441);
      case 'reducing':
        return const Color(0xFFDCC6A0);
      case 'budgeting':
        return const Color(0xFF4CAF50);
      case 'spending':
        return const Color(0xFFE53935);
      case 'trends':
        return const Color(0xFF1E88E5);
      case 'category':
        return const Color(0xFF8E24AA);
      case 'weekly':
        return const Color(0xFF00897B);
      case 'achievements':
        return const Color(0xFFFFB300);
      case 'unusual':
        return const Color(0xFFFF7043);
      case 'general':
        return const Color(0xFFB0B5BE);
      default:
        return const Color(0xFFB0B5BE);
    }
  }

  String _percentageForRecommendation(Recommendation rec) {
    final priorityPercent = (rec.priority / 10 * 100).clamp(0, 100);
    return '${priorityPercent.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredCats = filteredCategoryTotals;
    final filteredTotal = filteredTotalExpenses;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5EF),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFDF9),
          surfaceTintColor: const Color(0xFFFFFDF9),
          elevation: 0,
          title: const Text(
            'رؤاي المالية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                );
                if (result == true) loadData();
              },
              icon: const Icon(Icons.add_rounded, size: 26),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: loadData,
          color: const Color(0xFF2E7D32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // ── Behavior Cards Section ──
                _buildSectionHeader(
                  title: 'سلوكياتي',
                  trailingLabel: 'عرض الكل',
                ),
                const SizedBox(height: 10),
                _buildBehaviorCards(),

                const SizedBox(height: 24),

                // ── Financial Advisor Section ──
                _buildSectionHeader(
                  title: 'مرشدي المالي',
                ),
                const SizedBox(height: 8),
                _buildAdvisorSection(),

                const SizedBox(height: 24),

                // ── Statistics Section ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'احصائياتي',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF222222),
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StatisticsFilter(
                    selectedIndex: _selectedFilterIndex,
                    onSelected: (i) => setState(() => _selectedFilterIndex = i),
                  ),
                ),

                if (_selectedFilterIndex == 2) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MonthSelector(
                      currentMonth: currentMonth,
                      onPrevious: goToPreviousMonth,
                      onNext: goToNextMonth,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                if (filteredTotal > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ExpensePieChart(
                      categoryTotals: filteredCats,
                      totalExpenses: filteredTotal,
                    ),
                  )
                else
                  _buildEmptyChart(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Header ──

  Widget _buildSectionHeader({
    required String title,
    String? trailingLabel,
    VoidCallback? onTrailingTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
          ),
          if (trailingLabel != null)
            TextButton(
              onPressed: onTrailingTap ?? () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                trailingLabel,
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Behavior Cards ──

  Widget _buildBehaviorCards() {
    final cards = <BehaviorCard>[];
    final listHeight = MediaQuery.of(context).size.height * 0.237;

    if (recommendations.isEmpty) {
      cards.add(const BehaviorCard(
        icon: Icons.lightbulb_rounded,
        percentage: '0%',
        title: 'ابدأ رحلتك',
        description: 'أضف مصروفاتك للحصول على نصائح مالية مخصصة',
        accentColor: Color(0xFF2E7D32),
      ));
    } else {
      for (final rec in recommendations.take(5)) {
        cards.add(BehaviorCard(
          icon: _iconForCategory(rec.category),
          percentage: _percentageForRecommendation(rec),
          title: _arabicTitleForCategory(rec.category),
          description: rec.message,
          accentColor: _colorForCategory(rec.category),
        ));
      }
    }

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cards.length,
        itemBuilder: (_, i) => cards[i],
      ),
    );
  }

  // ── Advisor Section ──

  Widget _buildAdvisorSection() {
    if (financialAdvice.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: AdvisorRecommendationCard(
          title: 'مرشدي المالي',
          message: 'أضف مصروفاتك وأهدافك للحصول على نصائح مالية مخصصة.',
          avatarAsset: 'assets/images/advisor.png',
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: financialAdvice.take(2).map((advice) {
          return AdvisorRecommendationCard(
            title: advice.title,
            message: advice.message,
            avatarAsset: 'assets/images/advs.png',
          );
        }).toList(),
      ),
    );
  }

  // ── Empty Chart ──

  Widget _buildEmptyChart() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.pie_chart_outline_rounded,
                size: 48,
                color: const Color(0xFFB0B5BE).withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'لا توجد مصروفات في هذه الفترة',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

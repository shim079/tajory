import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/financial_goal.dart';
import '../services/firestore_service.dart';
import '../widgets/goal_card.dart';
import 'add_savings_screen.dart';
import 'add_goal_screen.dart';

class MyGoalsScreen extends StatefulWidget {
  const MyGoalsScreen({super.key});

  @override
  State<MyGoalsScreen> createState() => _MyGoalsScreenState();
}

class _MyGoalsScreenState extends State<MyGoalsScreen> {
  final firestoreService = FirestoreService();
  List<FinancialGoal> goals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final gs = await firestoreService.getGoals(user.uid);
      if (!mounted) return;
      setState(() {
        goals = gs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load goals: $e')),
      );
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _openAddGoal() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddGoalScreen()),
    );
    if (created == true) loadGoals();
  }

  Future<void> _openAddSavings(FinancialGoal goal) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddSavingsScreen(preselectedGoalId: goal.id),
      ),
    );
    if (updated == true) loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final green = const Color(0xFF2E7D32);
    final padH = MediaQuery.of(context).size.width * 0.041;

    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFDF9),
        surfaceTintColor: const Color(0xFFFFFDF9),
        title: Text(
          'اهدافي',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        actions: [
          IconButton(
            onPressed: _openAddGoal,
            icon: const Icon(Icons.add_rounded, size: 26),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadGoals,
              color: green,
              child: activeGoals.isEmpty && completedGoals.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 80),
                        Icon(Icons.flag_outlined,
                            size: 72, color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text(
                          'لا أهداف حتى الآن',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط على زر + لإنشاء هدفك المالي الأول.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: EdgeInsets.fromLTRB(padH, 16, padH, 32),
                      children: [
                        if (activeGoals.isNotEmpty) ...[
                          const SizedBox(height: 25),
                          ...activeGoals.map((goal) => GoalCard(
                                goal: goal,
                                onTap: () => _openAddSavings(goal),
                              )),
                        ],
                        if (completedGoals.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'الأهداف المُنجزة',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...completedGoals.map((goal) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.check_circle,
                                      color: Color(0xFF2E7D32)),
                                  title: Text(
                                    goal.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'المدخر ${goal.target.toStringAsFixed(0)} ﷼',
                                  ),
                                ),
                              )),
                        ],
                      ],
                    ),
            ),
    );
  }
}

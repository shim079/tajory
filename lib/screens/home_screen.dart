import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/badge.dart' as badge_model;
import 'island_screen.dart';
import 'my_goals_screen.dart';
import 'financial_vision_screen.dart';
import 'my_account_screen.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final authService = AuthService();
  final firestoreService = FirestoreService();

  final _pages = <Widget>[
    const IslandScreen(),
    const MyGoalsScreen(),
    const SizedBox.shrink(),
    const FinancialVisionScreen(),
    const MyAccountScreen(),
  ];

  Future<void> openAddExpense() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddExpenseScreen(),
    );

    if (result == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await firestoreService.addExpense(
        uid: user.uid,
        amount: result['amount'] as double,
        category: result['category'] as String,
        description: result['description'] as String? ?? '',
        source: result['source'] as String? ?? 'manual',
      );

      final state = await firestoreService.getIslandState(user.uid);
      final evolved = state.evolve(10);
      await firestoreService.saveIslandState(uid: user.uid, state: evolved);

      await firestoreService.logActivity(
        uid: user.uid,
        action: 'add_expense',
        description:
            'Added \$${(result['amount'] as double).toStringAsFixed(2)} expense in ${result['category']}',
        xpEarned: 10,
      );

      await _checkBadges(user.uid);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added! +10 XP for your island.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add expense: $e')),
      );
    }
  }

  Future<void> _checkBadges(String uid) async {
    try {
      final unlocked = await firestoreService.getUnlockedBadgeIds(uid);
      final expenseCount = await firestoreService.getExpenseCount(uid);
      final goals = await firestoreService.getGoals(uid);
      final totalSaved = await firestoreService.calculateTotalSaved(uid);
      final island = await firestoreService.getIslandState(uid);

      for (final badge in badge_model.Badge.all) {
        if (unlocked.contains(badge.id)) continue;

        bool shouldUnlock = false;
        switch (badge.category) {
          case 'expenses':
            shouldUnlock = badge.id == 'first_expense'
                ? expenseCount >= 1
                : badge.id == 'expenses_10'
                    ? expenseCount >= 10
                    : expenseCount >= 50;
            break;
          case 'goals':
            final completedCount = goals.where((g) => g.isCompleted).length;
            shouldUnlock = badge.id == 'first_goal'
                ? goals.isNotEmpty
                : completedCount >= badge.requiredCount;
            break;
          case 'savings':
            shouldUnlock = totalSaved >= badge.requiredCount;
            break;
          case 'island':
            shouldUnlock = island.level >= badge.requiredCount;
            break;
        }

        if (shouldUnlock) {
          await firestoreService.unlockBadge(uid: uid, badge: badge);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        height: 72,
        color: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.landscape_rounded, 'My Island'),
              _navItem(1, Icons.flag_rounded, 'My Goals'),
              const SizedBox(width: 48),
              _navItem(3, Icons.trending_up_rounded, 'Vision'),
              _navItem(4, Icons.person_rounded, 'Account'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: openAddExpense,
        tooltip: 'Add Expense',
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

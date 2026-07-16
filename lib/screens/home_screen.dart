import 'package:flutter/material.dart';
import 'island_screen.dart';
import 'my_goals_screen.dart';
import 'financial_vision_screen.dart';
import 'my_account_screen.dart';
import 'add_savings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = <Widget>[
    const IslandScreen(),
    const MyGoalsScreen(),
    const SizedBox.shrink(),
    const FinancialVisionScreen(),
    const MyAccountScreen(),
  ];

  void _openAddSavings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddSavingsScreen()),
    );
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
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
          _navItem(0, Icons.landscape_rounded, 'واحتي'),
          _navItem(1, Icons.flag_rounded, 'اهدافي'),
          _navItemTextOnly('اضافة ادخار'),
          _navItem(3, Icons.trending_up_rounded, 'رؤاي المالية'),
          _navItem(4, Icons.person_rounded, 'حسابي'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        onPressed: _openAddSavings,
        tooltip: 'اضافة ادخار',
        shape: const CircleBorder(),
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
          const SizedBox(height: 4),
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

  Widget _navItemTextOnly(String label) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MonthNavigator extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthNavigator({
    super.key,
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  String get _monthYear {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[currentMonth.month - 1]} ${currentMonth.year}';
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return currentMonth.month == now.month && currentMonth.year == now.year;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Previous month',
        ),
        const SizedBox(width: 8),
        Text(
          _monthYear,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _isCurrentMonth ? null : onNext,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'Next month',
        ),
      ],
    );
  }
}

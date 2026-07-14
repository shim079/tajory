import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  static const _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  const MonthSelector({
    super.key,
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return currentMonth.month == now.month && currentMonth.year == now.year;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = _arabicMonths[currentMonth.month - 1];
    final year = currentMonth.year;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF222222),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Text(
              '$monthName $year',
              key: ValueKey('$monthName$year'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF222222),
              ),
            ),
          ),
          IconButton(
            onPressed: _isCurrentMonth ? null : onNext,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: _isCurrentMonth
                  ? const Color(0xFFB0B5BE)
                  : const Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}

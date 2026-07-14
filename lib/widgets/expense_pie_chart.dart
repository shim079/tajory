import 'package:flutter/material.dart';
import 'donut_chart.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final double totalExpenses;

  static const _designColors = {
    'Food': Color(0xFF2E7D32),
    'Shopping': Color(0xFFDCC6A0),
    'Bills': Color(0xFFB0B5BE),
    'Transportation': Color(0xFFD9A441),
    'Entertainment': Color(0xFF4CAF50),
    'Healthcare': Color(0xFF2E7D32),
    'Education': Color(0xFFD9A441),
    'Other': Color(0xFFB0B5BE),
  };

  static const _categoryLabels = {
    'Food': 'طعام',
    'Shopping': 'تسوق',
    'Bills': 'فواتير',
    'Transportation': 'نقل',
    'Entertainment': 'ترفيه',
    'Healthcare': 'صحة',
    'Education': 'تعليم',
    'Other': 'أخرى',
  };

  const ExpensePieChart({
    super.key,
    required this.categoryTotals,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
                DonutChart(
                  data: categoryTotals,
                  size: 120,
                  strokeWidth: 20,
                  categoryColors: _designColors,
                  showLegend: false,
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '﷼ ${totalExpenses.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'إجمالي المصروفات',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF666666),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categoryTotals.entries.map((entry) {
              final color = _designColors[entry.key] ?? const Color(0xFFB0B5BE);
              final label = _categoryLabels[entry.key] ?? entry.key;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF222222),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

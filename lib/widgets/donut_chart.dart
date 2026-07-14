import 'dart:math';
import 'package:flutter/material.dart';

class DonutChart extends StatelessWidget {
  final Map<String, double> data;
  final double size;
  final double strokeWidth;
  final Map<String, Color>? categoryColors;
  final bool showLegend;

  static const _categoryColors = {
    'Food': Color(0xFF4CAF50),
    'Shopping': Color(0xFFFF9800),
    'Bills': Color(0xFF2196F3),
    'Transportation': Color(0xFF9C27B0),
    'Entertainment': Color(0xFFE91E63),
    'Healthcare': Color(0xFF00BCD4),
    'Education': Color(0xFF3F51B5),
    'Other': Color(0xFF607D8B),
  };

  const DonutChart({
    super.key,
    required this.data,
    this.size = 200,
    this.strokeWidth = 40,
    this.categoryColors,
    this.showLegend = true,
  });

  Color _colorFor(String category, int index) {
    if (categoryColors != null && categoryColors!.containsKey(category)) {
      return categoryColors![category]!;
    }
    return _categoryColors[category] ?? Color.lerp(Colors.blue, Colors.purple, (index % 10) / 10)!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = data.values.fold<double>(0, (a, b) => a + b);

    if (total <= 0) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            'No data',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final entries = data.entries.toList();
    final chartSize = size + strokeWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: chartSize,
          height: chartSize,
          child: CustomPaint(
            size: Size(chartSize, chartSize),
            painter: _DonutPainter(
              entries: entries,
              total: total,
              strokeWidth: strokeWidth,
              colorFor: _colorFor,
            ),
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 16),
          ...entries.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final percent = total > 0 ? (e.value / total) * 100 : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _colorFor(e.key, i),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${e.key}  \$${e.value.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 4),
                Text(
                  '(${percent.toStringAsFixed(1)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),
        ],
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double total;
  final double strokeWidth;
  final Color Function(String, int) colorFor;

  _DonutPainter({
    required this.entries,
    required this.total,
    required this.strokeWidth,
    required this.colorFor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final sweepAngle = (entry.value / total) * 2 * pi;

      paint.color = colorFor(entry.key, i);
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.entries != entries || oldDelegate.total != total;
  }
}

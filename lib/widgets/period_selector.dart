import 'package:flutter/material.dart';

enum Period { daily, weekly, monthly }

class PeriodSelector extends StatelessWidget {
  final Period selected;
  final ValueChanged<Period> onChanged;

  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Period>(
      segments: const [
        ButtonSegment(value: Period.daily, label: Text('Daily')),
        ButtonSegment(value: Period.weekly, label: Text('Weekly')),
        ButtonSegment(value: Period.monthly, label: Text('Monthly')),
      ],
      selected: {selected},
      onSelectionChanged: (sel) => onChanged(sel.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

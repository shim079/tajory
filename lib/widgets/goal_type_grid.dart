import 'package:flutter/material.dart';
import 'goal_type_card.dart';

class GoalTypeGrid extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onSelected;

  static const _types = [
    _GoalType('Home', '\u{1F3E0}', '\u0627\u0644\u0628\u064A\u062A'),
    _GoalType('Education', '\u{1F4DA}', '\u0627\u0644\u062F\u0631\u0627\u0633\u0629'),
    _GoalType('Travel', '\u{1F9F3}', '\u0627\u0644\u0633\u0641\u0631'),
    _GoalType('Car', '\u{1F697}', '\u0627\u0644\u0633\u064A\u0627\u0631\u0629'),
    _GoalType('Marriage', '\u{1F48D}', '\u0627\u0644\u0632\u0648\u0627\u062C'),
    _GoalType('Emergencies', '\u{1F3E6}', '\u0627\u0644\u0637\u0648\u0627\u0631\u0626'),
    _GoalType('New Device', '\u{1F4BB}', '\u0627\u0644\u062C\u0647\u0627\u0632'),
    _GoalType('Other', '\u{1F4B0}', '\u0623\u062E\u0631\u0649'),
  ];

  const GoalTypeGrid({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _types.map((type) {
        return GoalTypeCard(
          label: type.arabicLabel,
          emoji: type.emoji,
          isSelected: selectedType == type.id,
          onTap: () => onSelected(type.id),
        );
      }).toList(),
    );
  }
}

class _GoalType {
  final String id;
  final String emoji;
  final String arabicLabel;

  const _GoalType(this.id, this.emoji, this.arabicLabel);
}

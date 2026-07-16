import 'package:flutter/material.dart';
import '../models/financial_goal.dart';
import '../utils/goal_image_helper.dart';

class GoalSelectorCard extends StatelessWidget {
  final FinancialGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalSelectorCard({
    super.key,
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final green = const Color(0xFF2E7D32);
    final cardWidth = MediaQuery.of(context).size.width * 0.33;
    final imageSize = cardWidth * 0.37;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cardWidth,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? green.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? green : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                getGoalImageForGoal(goal.title, goal.goalType),
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              goal.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? green : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'المتبقي:  ${goal.remaining.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

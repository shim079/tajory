import 'package:flutter/material.dart';
import '../models/financial_goal.dart';
import '../utils/goal_image_helper.dart';

class GoalCard extends StatelessWidget {
  final FinancialGoal goal;
  final VoidCallback? onTap;

  const GoalCard({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final green = const Color(0xFF2E7D32);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  getGoalImageForGoal(goal.title, goal.goalType),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الهدف: ${goal.target.toStringAsFixed(0)} ﷼',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: goal.progressPercent,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(green),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(goal.progressPercent * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المدخر: ${goal.saved.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'المتبقي: ${goal.remaining.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

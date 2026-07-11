import 'package:flutter/material.dart';

class AdvisorCard extends StatelessWidget {
  final String message;
  final bool isLoading;

  const AdvisorCard({
    super.key,
    required this.message,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth > 600 ? 20 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Advisor',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isLoading)
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.support_agent_rounded,
                color: theme.colorScheme.onPrimary,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

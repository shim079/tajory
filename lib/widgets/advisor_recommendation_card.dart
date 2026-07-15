import 'package:flutter/material.dart';

class AdvisorRecommendationCard extends StatelessWidget {
  final String avatarAsset;
  final String title;
  final String message;
  final Color avatarBgColor;
  final bool compact;

  const AdvisorRecommendationCard({
    super.key,
    this.avatarAsset = 'assets/images/adv.png',
    required this.title,
    required this.message,
    this.avatarBgColor = const Color(0xFF2E7D32),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 4 : 12),
      padding: EdgeInsets.all(compact ? 10 : 19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 10 : 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              avatarAsset,
              width: compact ? 32 : 48,
              height: compact ? 32 : 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: compact ? 32 : 48,
                height: compact ? 32 : 48,
                decoration: BoxDecoration(
                  color: avatarBgColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, color: avatarBgColor, size: compact ? 18 : 26),
              ),
            ),
          ),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: compact
                      ? theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF222222),
                        )
                      : theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF222222),
                        ),
                ),
                SizedBox(height: compact ? 4 : 6),
                Text(
                  message,
                  style: compact
                      ? theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF666666),
                          height: 1.4,
                        )
                      : theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF666666),
                          height: 1.5,
                        ),
                  maxLines: compact ? 2 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

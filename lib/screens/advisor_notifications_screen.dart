import 'package:flutter/material.dart';
import '../models/financial_advice.dart';

class AdvisorNotificationsScreen extends StatelessWidget {
  final List<FinancialAdvice> advice;

  const AdvisorNotificationsScreen({
    super.key,
    required this.advice,
  });

  IconData _iconForType(AdviceType type) {
    switch (type) {
      case AdviceType.budgetExceeded:
        return Icons.account_balance_wallet_rounded;
      case AdviceType.goalAtRisk:
        return Icons.flag_rounded;
      case AdviceType.lowSavings:
        return Icons.savings_rounded;
      case AdviceType.highSpending:
        return Icons.trending_up_rounded;
      case AdviceType.positiveAchievement:
        return Icons.emoji_events_rounded;
      case AdviceType.generalRecommendation:
        return Icons.lightbulb_rounded;
    }
  }

  Color _colorForType(AdviceType type) {
    switch (type) {
      case AdviceType.budgetExceeded:
        return const Color(0xFFE53935);
      case AdviceType.goalAtRisk:
        return const Color(0xFFD9A441);
      case AdviceType.lowSavings:
        return const Color(0xFFFF7043);
      case AdviceType.highSpending:
        return const Color(0xFFFF9800);
      case AdviceType.positiveAchievement:
        return const Color(0xFF2E7D32);
      case AdviceType.generalRecommendation:
        return const Color(0xFF4CAF50);
    }
  }

  String _labelForType(AdviceType type) {
    switch (type) {
      case AdviceType.budgetExceeded:
        return 'تجاوز الميزانية';
      case AdviceType.goalAtRisk:
        return 'هدف تحت ضغط';
      case AdviceType.lowSavings:
        return 'ادخار منخفض';
      case AdviceType.highSpending:
        return 'مصروفات عالية';
      case AdviceType.positiveAchievement:
        return 'انجاز';
      case AdviceType.generalRecommendation:
        return 'توصية';
    }
  }

  @override
  Widget build(BuildContext context) {
    final padH = MediaQuery.of(context).size.width * 0.051;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDF9),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFDF9),
          surfaceTintColor: const Color(0xFFFFFDF9),
          elevation: 0,
          title: const Text(
            'نصيحتي المالية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: advice.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_rounded,
                        size: 64,
                        color: const Color(0xFFB0B5BE).withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد نصائح حالياً',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF666666),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أضف مصروفاتك للحصول على نصائح مخصصة',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFB0B5BE),
                          ),
                    ),
                  ],
                ),
              )
            :               ListView.builder(
                padding: EdgeInsets.fromLTRB(padH, 8, padH, 32),
                itemCount: advice.length,
                itemBuilder: (_, i) {
                  final item = advice[i];
                  final color = _colorForType(item.type);
                  final icon = _iconForType(item.type);
                  final label = _labelForType(item.type);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF222222),
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.message,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF666666),
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

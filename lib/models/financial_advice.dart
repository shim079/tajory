enum AdviceType {
  budgetExceeded,
  goalAtRisk,
  lowSavings,
  highSpending,
  positiveAchievement,
  generalRecommendation,
}

class FinancialAdvice {
  final String title;
  final String message;
  final AdviceType type;
  final int priority;

  const FinancialAdvice({
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
  });
}

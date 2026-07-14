import '../models/financial_advice.dart';
import '../models/user_financial_data.dart';

class FinancialAdvisorService {
  static const _arabicCategory = {
    'Food': 'الطعام',
    'Shopping': 'التسوق',
    'Bills': 'الفواتير',
    'Transportation': 'النقل',
    'Entertainment': 'الترفيه',
    'Healthcare': 'الصحة',
    'Education': 'التعليم',
    'Other': 'الأخرى',
  };

  List<FinancialAdvice> generateAdvice(UserFinancialData data) {
    if (data.income <= 0) {
      return const [
        FinancialAdvice(
          title: 'بيانات مفقودة',
          message: 'حدد دخلك الشهري للحصول على نصائح مالية مخصصة.',
          type: AdviceType.generalRecommendation,
          priority: 10,
        ),
      ];
    }

    final advice = <FinancialAdvice>[];

    // ── Rule 1: Budget exceeded ──
    _checkBudgetExceeded(data, advice);

    // ── Rule 2: Goals at risk ──
    _checkGoalsAtRisk(data, advice);

    // ── Rule 3: Goal savings allocation ──
    _checkGoalSavingsAllocation(data, advice);

    // ── Rule 4: Low savings ──
    _checkLowSavings(data, advice);

    // ── Rule 5: High spending ──
    _checkHighSpending(data, advice);

    // ── Rule 6: Positive achievements ──
    _checkAchievements(data, advice);

    // ── Rule 7: General recommendations ──
    _checkGeneral(data, advice);

    // Sort by priority (lower = more urgent), deduplicate, limit 2-4
    advice.sort((a, b) => a.priority.compareTo(b.priority));
    final unique = <FinancialAdvice>[];
    final seenTitles = <String>{};
    for (final a in advice) {
      if (!seenTitles.contains(a.title)) {
        seenTitles.add(a.title);
        unique.add(a);
      }
    }

    return unique.take(4).toList();
  }

  // ══════════════════════════════════════════════════════════════
  //  RULES
  // ══════════════════════════════════════════════════════════════

  /// Rule 1: Budget exceeded / close to limit
  void _checkBudgetExceeded(UserFinancialData data, List<FinancialAdvice> advice) {
    if (data.categoryTotals.isEmpty || data.income <= 0) return;

    // If user has goals, budget limit considers goal funding needs
    final goalBudgetDeduction = data.activeGoals.fold<double>(0, (sum, g) {
      if (g.deadline != null && g.daysRemaining != null && g.daysRemaining! > 0) {
        return sum + (g.remaining / g.daysRemaining! * 30);
      }
      return sum;
    });

    final budgetLimit = (data.income * 0.30) - goalBudgetDeduction * 0.5;

    final sorted = data.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted) {
      if (entry.value > budgetLimit) {
        final percent = (entry.value / data.income * 100).toStringAsFixed(0);
        final arabic = _arabicCategory[entry.key] ?? entry.key;
        advice.add(FinancialAdvice(
          title: 'تجاوز الميزانية',
          message: 'مصروفات "$arabic" وصلت ﷼${entry.value.toStringAsFixed(0)} ($percent% من دخلك). حدد حد أقصى ﷼${budgetLimit.toStringAsFixed(0)} لهذا التصنيف.',
          type: AdviceType.budgetExceeded,
          priority: 1,
        ));
        break; // Only highest priority budget alert
      }
    }

    // Check if total spending is close to income
    if (data.spendingPercent > 85) {
      final remaining = (data.income - data.totalExpenses).clamp(0, double.infinity);
      advice.add(FinancialAdvice(
        title: 'تحذير الميزانية',
        message: 'لقد أنفقت ${data.spendingPercent.toStringAsFixed(0)}% من دخلك. متبقي ﷼${remaining.toStringAsFixed(0)} فقط.',
        type: AdviceType.budgetExceeded,
        priority: 1,
      ));
    }
  }

  /// Rule 2: Goals at risk
  void _checkGoalsAtRisk(UserFinancialData data, List<FinancialAdvice> advice) {
    for (final goal in data.activeGoals) {
      // Goal overdue
      if (goal.daysRemaining != null && goal.daysRemaining! < 0) {
        advice.add(FinancialAdvice(
          title: 'هدف متأخر',
          message: '"${goal.title}" تجاوز موعد الانتهاء. عدّل الهدف أو زِد معدل الادخار.',
          type: AdviceType.goalAtRisk,
          priority: 2,
        ));
        continue;
      }

      // Goal deadline approaching and behind schedule
      if (goal.daysRemaining != null &&
          goal.daysRemaining! <= 30 &&
          goal.progressPercent < 0.7) {
        final needed = goal.remaining;
        final perDay = goal.daysRemaining! > 0
            ? (needed / goal.daysRemaining!).toStringAsFixed(0)
            : '0';
        advice.add(FinancialAdvice(
          title: 'هدف تحت ضغط',
          message: '"${goal.title}" متبقي ${goal.daysRemaining} يوماً. تحتاج ﷼${needed.toStringAsFixed(0)} — أي ﷼$perDay يومياً.',
          type: AdviceType.goalAtRisk,
          priority: 2,
        ));
        continue;
      }

      // Goal far behind — suggest increasing savings
      if (goal.progressPercent < 0.25 && goal.daysRemaining != null && goal.daysRemaining! > 30) {
        final needed = goal.remaining;
        final monthsLeft = (goal.daysRemaining! / 30).ceil();
        final perMonth = monthsLeft > 0 ? (needed / monthsLeft).toStringAsFixed(0) : '0';
        advice.add(FinancialAdvice(
          title: 'هدف متأخر',
          message: '"${goal.title}" وصلت فقط ${(goal.progressPercent * 100).toStringAsFixed(0)}%. تحتاج ﷼$perMonth شهرياً لمدة $monthsLeft أشهر للإلحاق.',
          type: AdviceType.goalAtRisk,
          priority: 2,
        ));
        continue;
      }

      // Goal almost done — encourage
      if (goal.progressPercent >= 0.75 && goal.progressPercent < 1.0) {
        advice.add(FinancialAdvice(
          title: 'هدف قريب من الإتمام',
          message: '"${goal.title}" وصل ${(goal.progressPercent * 100).toStringAsFixed(0)}%. واصل بنفس الوتيرة!',
          type: AdviceType.positiveAchievement,
          priority: 5,
        ));
      }
    }

    // Completed goals
    if (data.completedGoals.isNotEmpty) {
      advice.add(FinancialAdvice(
        title: 'هدف مكتمل',
        message: 'تهانينا! أتممت "${data.completedGoals.first.title}". أنت في المسار الصحيح.',
        type: AdviceType.positiveAchievement,
        priority: 5,
      ));
    }
  }

  /// Rule 3: Goal savings allocation — how much goes to goals vs general savings
  void _checkGoalSavingsAllocation(UserFinancialData data, List<FinancialAdvice> advice) {
    if (data.activeGoals.isEmpty || data.savingRate <= 0) return;

    final currentSavings = data.income - data.totalExpenses;
    if (currentSavings <= 0) return;

    // Calculate total needed for all active goals
    final totalGoalNeeded = data.activeGoals.fold<double>(0, (sum, g) => sum + g.remaining);

    // Check if savings pace aligns with goal deadlines
    for (final goal in data.activeGoals) {
      if (goal.daysRemaining == null || goal.daysRemaining! <= 0) continue;

      final monthsLeft = (goal.daysRemaining! / 30).ceil();
      if (monthsLeft <= 0) continue;

      final neededPerMonth = goal.remaining / monthsLeft;

      if (currentSavings < neededPerMonth) {
        final gap = (neededPerMonth - currentSavings).toStringAsFixed(0);
        advice.add(FinancialAdvice(
          title: 'ادخار غير كافٍ للهدف',
          message: 'ادخارك الحالي ﷼${currentSavings.toStringAsFixed(0)} أقل من المطلوب ﷼${neededPerMonth.toStringAsFixed(0)} شهرياً للهدف "${goal.title}". حاول زيادة الادخار بـ ﷼$gap شهرياً.',
          type: AdviceType.lowSavings,
          priority: 3,
        ));
        break;
      }
    }

    // If savings rate is good but no dedicated goal allocation
    if (data.savingRate >= 20 && totalGoalNeeded > 0) {
      final goalAllocationPercent = ((currentSavings * 0.6) / data.income * 100).toStringAsFixed(0);
      advice.add(FinancialAdvice(
        title: 'تخصيص الادخار للأهداف',
        message: 'وفّرت ${data.savingRate.toStringAsFixed(0)}% هذا الشهر. خصص 60% من الادخار (≈$goalAllocationPercent% من الدخل) للأهداف النشطة لتسريع الإنجاز.',
        type: AdviceType.generalRecommendation,
        priority: 6,
      ));
    }
  }

  /// Rule 4: Low savings
  void _checkLowSavings(UserFinancialData data, List<FinancialAdvice> advice) {
    if (data.savingRate <= 0 && data.totalExpenses >= data.income) {
      final goalHint = data.activeGoals.isNotEmpty
          ? 'سيساعدك ذلك في تمويل "${data.activeGoals.first.title}".'
          : 'حتى ﷼10 يومياً تعادل ﷼3,600 سنوياً.';
      advice.add(FinancialAdvice(
        title: 'لا ادخار',
        message: 'لم يتم تحويل أي مبلغ للادخار هذا الشهر. $goalHint',
        type: AdviceType.lowSavings,
        priority: 3,
      ));
    } else if (data.savingRate < 10) {
      advice.add(FinancialAdvice(
        title: 'ادخار منخفض',
        message: 'معدل الادخار ${data.savingRate.toStringAsFixed(0)}% فقط. حاول خصم 5% من المصروفات الترفيهية.',
        type: AdviceType.lowSavings,
        priority: 3,
      ));
    }

    // Compare with previous month savings
    if (data.previousMonthSavings != null && data.previousMonthSavings! > 0) {
      final currentSavings = data.income - data.totalExpenses;
      if (currentSavings < data.previousMonthSavings! * 0.7) {
        final decrease = ((data.previousMonthSavings! - currentSavings) / data.previousMonthSavings! * 100).toStringAsFixed(0);
        advice.add(FinancialAdvice(
          title: 'انخفاض الادخار',
          message: 'وفّرت $decrease% أقل من الشهر الماضي. خصم المبلغ بعد استلام الراتب يضمن الادخار.',
          type: AdviceType.lowSavings,
          priority: 3,
        ));
      }
    }
  }

  /// Rule 5: High spending / category analysis
  void _checkHighSpending(UserFinancialData data, List<FinancialAdvice> advice) {
    // Spending vs previous month
    if (data.previousMonthExpenses != null && data.previousMonthExpenses! > 0) {
      final change = ((data.totalExpenses - data.previousMonthExpenses!) / data.previousMonthExpenses! * 100);

      if (change > 15) {
        advice.add(FinancialAdvice(
          title: 'ارتفاع المصروفات',
          message: 'مصروفاتك زادت ${change.toStringAsFixed(0)}% عن الشهر الماضي. راجع المشتريات الأخيرة.',
          type: AdviceType.highSpending,
          priority: 4,
        ));
      } else if (change < -15) {
        advice.add(FinancialAdvice(
          title: 'انخفاض المصروفات',
          message: 'مصروفاتك انخفضت ${change.abs().toStringAsFixed(0)}% عن الشهر الماضي. تقدم ممتاز!',
          type: AdviceType.positiveAchievement,
          priority: 5,
        ));
      }
    }

    // Top category analysis — tie to goals if active
    if (data.categoryTotals.isNotEmpty && data.totalExpenses > 0) {
      final sorted = data.categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final top = sorted.first;
      final topPercent = (top.value / data.totalExpenses * 100);
      if (topPercent > 35) {
        final arabic = _arabicCategory[top.key] ?? top.key;
        String message = '"$arabic" يشكل ${topPercent.toStringAsFixed(0)}% من مصروفاتك (﷼${top.value.toStringAsFixed(0)}).';

        if (data.activeGoals.isNotEmpty) {
          final goalName = data.activeGoals.first.title;
          final potentialSaving = (top.value * 0.2).toStringAsFixed(0);
          message += ' خفضه بنسبة 20% يوفر ﷼$potentialSaving يمكن توجيهها لهدف "$goalName".';
        } else {
          message += ' تنويع الإنفاق يحسن التوازن المالي.';
        }

        advice.add(FinancialAdvice(
          title: 'تركيز عالي في فئة',
          message: message,
          type: AdviceType.highSpending,
          priority: 4,
        ));
      }
    }
  }

  /// Rule 6: Positive achievements
  void _checkAchievements(UserFinancialData data, List<FinancialAdvice> advice) {
    // Good saving rate
    if (data.savingRate >= 20) {
      advice.add(FinancialAdvice(
        title: 'ادخار ممتاز',
        message: 'وفّرت ${data.savingRate.toStringAsFixed(0)}% من دخلك هذا الشهر (﷼${(data.income - data.totalExpenses).toStringAsFixed(0)}). أنت تبني وسادة مالية قوية!',
        type: AdviceType.positiveAchievement,
        priority: 5,
      ));
    }

    // Spending down + savings up
    if (data.previousMonthExpenses != null &&
        data.previousMonthExpenses! > 0 &&
        data.previousMonthSavings != null) {
      final currentSavings = data.income - data.totalExpenses;
      final spendingDown = data.totalExpenses < data.previousMonthExpenses!;
      final savingsUp = currentSavings > data.previousMonthSavings!;

      if (spendingDown && savingsUp) {
        advice.add(const FinancialAdvice(
          title: 'تقدم مالي',
          message: 'مصروفاتك انخفضت وادخارك زاد مقارنة بالشهر الماضي. أنت على المسار الصحيح!',
          type: AdviceType.positiveAchievement,
          priority: 5,
        ));
      }
    }

    // Goal milestones achieved
    for (final goal in data.activeGoals) {
      final milestone = goal.milestonesReached;
      if (milestone > 0 && milestone < 4) {
        final percent = (goal.progressPercent * 100).toStringAsFixed(0);
        advice.add(FinancialAdvice(
          title: 'إنجاز في الهدف',
          message: '"${goal.title}" وصل $percent%! $milestone من 4 مراحل مكتملة.',
          type: AdviceType.positiveAchievement,
          priority: 5,
        ));
        break;
      }
    }
  }

  /// Rule 7: General recommendations
  void _checkGeneral(UserFinancialData data, List<FinancialAdvice> advice) {
    if (data.activeGoals.isEmpty && data.completedGoals.isEmpty) {
      advice.add(const FinancialAdvice(
        title: 'تحديد هدف',
        message: 'حدد هدفاً مالياً مثل "صندوق الطوارئ" لتركيز جهدك المالي.',
        type: AdviceType.generalRecommendation,
        priority: 6,
      ));
    }

    if (data.savingRate >= 10 && data.savingRate < 20) {
      advice.add(FinancialAdvice(
        title: 'تحسين الادخار',
        message: 'أنت توفر ${data.savingRate.toStringAsFixed(0)}%. الوصول إلى 20% يُنشئ وسادة مالية في غضون أشهر.',
        type: AdviceType.generalRecommendation,
        priority: 6,
      ));
    }

    // Goal-specific: suggest new goal type if user only has one type
    if (data.activeGoals.length == 1) {
      final existing = data.activeGoals.first.title.toLowerCase();
      if (!existing.contains('طوارئ') && !existing.contains('صندوق')) {
        advice.add(const FinancialAdvice(
          title: 'تنويع الأهداف',
          message: 'لديك هدف واحد فقط. أضف "صندوق طوارئ" يغطي 3-6 أشهر من مصروفاتك للحماية المالية.',
          type: AdviceType.generalRecommendation,
          priority: 6,
        ));
      }
    }
  }
}

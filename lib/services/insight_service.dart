import 'dart:math';
import '../models/expense.dart';
import '../models/financial_goal.dart';
import '../models/recommendation.dart';

class InsightService {
  // ── Arabic category labels ──
  static const _arabicCategory = {
    'Food': 'طعام',
    'Shopping': 'تسوق',
    'Bills': 'فواتير',
    'Transportation': 'نقل',
    'Entertainment': 'ترفيه',
    'Healthcare': 'صحة',
    'Education': 'تعليم',
    'Other': 'أخرى',
  };

  // ── Category-specific actionable tips (Arabic) ──
  static const _categoryTips = {
    'Food': [
      'الطبخ في المنزل مرتين أسبوعياً بدلاً من تناول الطعام في المطاعم يمكن أن يوفر لك حوالي ﷼400 شهرياً.',
      'التخطيط لوجبات الأسبوع يقلل من هدر الطعام والتكاليف.',
      'تجنّب الطلب عبر الإنترنت في أيام الأسبوع — وصفة وجبة منزلية أرخص بـ 70%.',
    ],
    'Shopping': [
      'انتظر 48 ساعة قبل أي شراء غير أساسي — كثير من المشتريات تصبح غير ضرورية.',
      'ألغِ الاشتراكات التي لم تستخدمها في آخر 30 يوماً لتوفير حوالي ﷼120 شهرياً.',
      'اشترِ المنتجات الأساسية بالجملة لتوفير 15-20% سنوياً.',
    ],
    'Entertainment': [
      'خصّص ميزانية ثابتة للترفيه شهرياً وحاول عدم تجاوزها.',
      'استخدم الخدمات المجانية بدلاً من الاشتراكات المدفوعة.',
      'أ Weekend بلا إنفاق مرة واحدة شهرياً يوفر لك ﷼200 على الأقل.',
    ],
    'Transportation': [
      'المشي أو ركوب الدراجة للمسافات القصيرة يوفر الوقود ويحسن الصحة.',
      'ادّخر رحلاتك في يوم واحد لتقليل تكاليف النقل.',
      'استخدم تطبيقات مشاركة الرحلات لتقليل تكلفة التنقل.',
    ],
    'Bills': [
      'راجع فواتير الخدمات — قد تجد أسعار أفضل من مزودين آخرين.',
      'أوقف الأجهزة غير المستخدمة لتقليل فواتير الكهرباء.',
      'استخدم إعدادات توفير الطاقة في الأجهزة الكهربائية.',
    ],
    'Healthcare': [
      'احصل على فحص صحي دوري — الوقاية أرخص من العلاج.',
      'استخدم الصيدلية الحكومية بدلاً من الخاصة لتوفير تكاليف الأدوية.',
    ],
    'Education': [
      'استخدم الموارد التعليمية المجانية عبر الإنترنت قبل الدفع للكورسات.',
      'استعار الكتب من المكتبة بدلاً من شرائها.',
    ],
    'Other': [
      'تتبع مصروفاتك لمدة أسبوع لتحديد الثغرات المالية.',
      'استخدم قاعدة 50/30/20: 50% احتياجات، 30% رغبات، 20% ادخار.',
    ],
  };

  // ── Habit tips (Arabic) ──
  static const _habitTips = {
    'saving': [
      'حوّل ﷼15 يومياً إلى ادخار — ستحصل على أكثر من ﷼5,000 خلال سنة.',
      'أعد تحويل المبلغ المتبقي من ميزانية البقالة إلى هدف الادخار.',
      'استخدم قاعدة التقريب: اجمع كل المبلغ إلى أقرب 10 وادّخر الفرق.',
      'احتفظ بقائمة "المشتريات التي تรอنا" — أكمل 30 يوماً قبل الشراء.',
    ],
    'budgeting': [
      'تتبع كل مصروف لمدة أسبوع لتحديد أماكن تسرب الأموال.',
      'استخدم ظروف نقدية لكل فئة تنفق أكثر من حدّها.',
      'خصّص مبلغ ثابت للترفيه شهرياً وعدم تجاوزه.',
      'جرّب عطلة إنفاق مرة واحدة شهرياً.',
    ],
    'reducing': [
      'ألغِ الاشتراكات غير المستخدمة في آخر 30 يوماً.',
      'اشترِ المنتجات العامة بدلاً من العلامات التجارية.',
      'انتظر 48 ساعة قبل أي شراء غير أساسي.',
      'اكتب قائمة مشترياتك قبل الذهاب للمتجر التزم بها.',
    ],
  };

  // ══════════════════════════════════════════════════════════════════
  //  MAIN GENERATOR — Comprehensive Arabic Insights
  // ══════════════════════════════════════════════════════════════════

  List<Recommendation> generateRecommendations({
    required double income,
    required double expenses,
    required String habitType,
    required List<FinancialGoal> goals,
    List<Expense>? allExpenses,
    Map<String, double>? categoryTotals,
    double? previousMonthExpenses,
  }) {
    final recommendations = <Recommendation>[];
    final now = DateTime.now();
    int priority = 10;

    if (income <= 0) {
      recommendations.add(Recommendation(
        id: 'setup_income',
        message: 'حدد دخلك الشهري للحصول على نصائح مالية مخصصة.',
        category: 'general',
        priority: priority,
        createdAt: now,
      ));
      return recommendations;
    }

    final savings = income - expenses;
    final savingRate = income > 0 ? ((savings / income) * 100).clamp(0, 100) : 0.0;
    final spendingPercent = income > 0 ? ((expenses / income) * 100).clamp(0, 100) : 0.0;

    // ── 💰 Savings Analysis ──
    if (savingRate >= 20) {
      recommendations.add(Recommendation(
        id: 'excellent_saving',
        message: 'وفّرت ﷼${savings.toStringAsFixed(0)} هذا الشهر، وهو ${savingRate.toStringAsFixed(0)}% من دخلك. أنت تبني وسادة مالية قوية!',
        category: 'saving',
        priority: --priority,
        createdAt: now,
      ));
    } else if (savingRate >= 10) {
      recommendations.add(Recommendation(
        id: 'moderate_saving',
        message: 'معدل الادخار لديك ${savingRate.toStringAsFixed(0)}% — جيد لكن يمكنك تحسينه. حاول الوصول إلى 20% بتقليل المصروفات الترفيهية.',
        category: 'saving',
        priority: --priority,
        createdAt: now,
      ));
    } else if (savingRate > 0) {
      recommendations.add(Recommendation(
        id: 'low_saving',
        message: 'معدل الادخار ${savingRate.toStringAsFixed(0)}% فقط هذا الشهر. حاول خصم 5% إضافية من المصروفات غير الضرورية.',
        category: 'saving',
        priority: --priority,
        createdAt: now,
      ));
    } else if (expenses >= income) {
      recommendations.add(Recommendation(
        id: 'no_saving',
        message: 'لم يتم تحويل أي مبلغ للادخار هذا الشهر. حتى إضافة ﷼10 يومياً يمكن أن تفرق كثيراً خلال العام.',
        category: 'saving',
        priority: --priority,
        createdAt: now,
      ));
    }

    // ── 🚨 Spending Alerts ──
    if (spendingPercent > 90) {
      recommendations.add(Recommendation(
        id: 'critical_spending',
        message: 'لقد أنفقت ${spendingPercent.toStringAsFixed(0)}% من دخلك! متبقي ${10 - now.day} أيام على نهاية الشهر. حان وقت تقليص المصروفات.',
        category: 'spending',
        priority: --priority,
        createdAt: now,
      ));
    } else if (spendingPercent > 70) {
      recommendations.add(Recommendation(
        id: 'high_spending',
        message: 'صرفت ${spendingPercent.toStringAsFixed(0)}% من دخلك. راجع مصاريفك لتجنب النفاد قبل نهاية الشهر.',
        category: 'spending',
        priority: --priority,
        createdAt: now,
      ));
    } else if (spendingPercent < 50 && savings > 0) {
      recommendations.add(Recommendation(
        id: 'healthy_spending',
        message: 'ممتاز! أنفقت ${spendingPercent.toStringAsFixed(0)}% فقط من دخلك. أنت على المسار الصحيح لبناء ثروة.',
        category: 'spending',
        priority: --priority,
        createdAt: now,
      ));
    }

    // ── 📈 Monthly Trends ──
    if (previousMonthExpenses != null && previousMonthExpenses > 0) {
      final change = ((expenses - previousMonthExpenses) / previousMonthExpenses) * 100;
      if (change < -10) {
        recommendations.add(Recommendation(
          id: 'spending_improved',
          message: 'مصروفاتك انخفضت ${change.abs().toStringAsFixed(0)}% مقارنة بالشهر الماضي. تقدم ممتاز!',
          category: 'trends',
          priority: --priority,
          createdAt: now,
        ));
      } else if (change > 20) {
        recommendations.add(Recommendation(
          id: 'spending_increased',
          message: 'مصروفاتك زادت ${change.toStringAsFixed(0)}% عن الشهر الماضي. راجع المشتريات الأخيرة.',
          category: 'trends',
          priority: --priority,
          createdAt: now,
        ));
      }
    }

    // ── 🎯 Goals Analysis ──
    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    if (activeGoals.isEmpty && completedGoals.isEmpty) {
      recommendations.add(Recommendation(
        id: 'set_goal',
        message: 'حدد هدفاً مالياً لتركيز جهدك. الأهداف الواضحة تزيد فرص النجاح.',
        category: 'goals',
        priority: --priority,
        createdAt: now,
      ));
    } else {
      for (final goal in activeGoals) {
        if (goal.deadline != null) {
          final daysLeft = goal.daysRemaining!;
          if (daysLeft < 0) {
            recommendations.add(Recommendation(
              id: 'goal_overdue_${goal.id}',
              message: 'هدف "${goal.title}" تجاوز الموعد المحدد! يمكنك تعديله أو تسريع الادخار.',
              category: 'goals',
              priority: --priority,
              createdAt: now,
            ));
          } else if (daysLeft <= 30 && goal.progressPercent < 0.7) {
            final needed = goal.remaining;
            final perDay = daysLeft > 0 ? (needed / daysLeft).toStringAsFixed(0) : '0';
            recommendations.add(Recommendation(
              id: 'goal_deadline_${goal.id}',
              message: 'هدف "${goal.title}" متبقي $daysLeft يوماً. تحتاج توفير ﷼${needed.toStringAsFixed(0)} — أي ﷼$perDay يومياً.',
              category: 'goals',
              priority: --priority,
              createdAt: now,
            ));
          }
        }

        if (goal.progressPercent >= 0.75 && goal.progressPercent < 1.0) {
          recommendations.add(Recommendation(
            id: 'goal_close_${goal.id}',
            message: 'أنت على وشك إتمام "${goal.title}" — وصلت ${(goal.progressPercent * 100).toStringAsFixed(0)}%! واصل بنفس الوتيرة.',
            category: 'goals',
            priority: --priority,
            createdAt: now,
          ));
        } else if (goal.progressPercent < 0.25) {
          recommendations.add(Recommendation(
            id: 'goal_behind_${goal.id}',
            message: 'هدف "${goal.title}" متأخر عن الجدول. زيادة ﷼300 شهرياً تساعدك على اللحاق بالموعد.',
            category: 'goals',
            priority: --priority,
            createdAt: now,
          ));
        }
      }

      for (final goal in completedGoals) {
        recommendations.add(Recommendation(
          id: 'goal_achieved_${goal.id}',
          message: 'تهانينا! أتممت "${goal.title}". أنت في المسار الصحيح.',
          category: 'achievements',
          priority: --priority,
          createdAt: now,
        ));
      }
    }

    // ── 🛒 Category Analysis ──
    if (categoryTotals != null && categoryTotals.isNotEmpty && expenses > 0) {
      final sorted = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sorted) {
        final percent = (entry.value / expenses) * 100;
        final arabicName = _arabicCategory[entry.key] ?? entry.key;

        if (percent > 30) {
          final tips = _categoryTips[entry.key] ?? _categoryTips['Other']!;
          final tip = tips[Random(now.day + entry.key.hashCode).nextInt(tips.length)];
          recommendations.add(Recommendation(
            id: 'category_high_${entry.key}',
            message: '$arabicName يمثل ${percent.toStringAsFixed(0)}% من مصروفاتك (﷼${entry.value.toStringAsFixed(0)}). $tip',
            category: 'category',
            priority: --priority,
            createdAt: now,
          ));
        }
      }
    }

    // ── 📊 Weekly Check-in ──
    if (allExpenses != null && allExpenses.isNotEmpty) {
      final now2 = DateTime.now();
      final thisWeekStart = now2.subtract(Duration(days: now2.weekday - 1));
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

      final thisWeekTotal = allExpenses
          .where((e) => e.date.isAfter(thisWeekStart.subtract(const Duration(days: 1))))
          .fold<double>(0, (s, e) => s + e.amount);

      final lastWeekTotal = allExpenses
          .where((e) =>
              e.date.isAfter(lastWeekStart.subtract(const Duration(days: 1))) &&
              e.date.isBefore(thisWeekStart))
          .fold<double>(0, (s, e) => s + e.amount);

      if (lastWeekTotal > 0 && thisWeekTotal < lastWeekTotal) {
        final decrease = ((lastWeekTotal - thisWeekTotal) / lastWeekTotal * 100);
        recommendations.add(Recommendation(
          id: 'weekly_improvement',
          message: 'صرفت ${decrease.toStringAsFixed(0)}% أقل هذا الأسبوع مقارنة بالأسبوع الماضي وأنت تحقق أهداف الادخار. واصل!',
          category: 'weekly',
          priority: --priority,
          createdAt: now,
        ));
      }
    }

    // ── 💡 Smart Habit Tips ──
    final habitTemplates = _habitTips[habitType] ?? _habitTips['saving']!;
    final rng = Random(now.millisecondsSinceEpoch);
    final template = habitTemplates[rng.nextInt(habitTemplates.length)];
    recommendations.add(Recommendation(
      id: 'habit_tip_$habitType',
      message: template,
      category: habitType,
      priority: --priority,
      createdAt: now,
    ));

    // ── 🏆 Achievements ──
    if (completedGoals.isNotEmpty) {
      recommendations.add(Recommendation(
        id: 'achievement_goals',
        message: 'لقد أتممت ${completedGoals.length} ${completedGoals.length == 1 ? 'هدف' : 'أهداف'} — أنت على الطريق الصحيح!',
        category: 'achievements',
        priority: --priority,
        createdAt: now,
      ));
    }

    if (savingRate >= 20 && expenses < income * 0.7) {
      recommendations.add(Recommendation(
        id: 'achievement_budget',
        message: 'تهانينا! حافظت على الميزانية لمدة ${now.month} ${now.month == 1 ? 'شهر' : 'أشهر'}. إنضباط مالي ممتاز!',
        category: 'achievements',
        priority: --priority,
        createdAt: now,
      ));
    }

    return recommendations;
  }

  // ══════════════════════════════════════════════════════════════════
  //  INSIGHT SUMMARY (Arabic)
  // ══════════════════════════════════════════════════════════════════

  String generateInsight(double income, double expenses) {
    if (income == 0) {
      return 'حدد دخلك للحصول على رؤية مالية شاملة.';
    }

    final ratio = (expenses / income) * 100;
    final savings = income - expenses;

    if (ratio < 30) {
      return 'ممتاز! أنفقت ${ratio.toStringAsFixed(0)}% فقط من دخلك ووفّرت ﷼${savings.toStringAsFixed(0)}. أنت تبني مستقبلاً مالياً قوياً.';
    } else if (ratio < 50) {
      return 'جيد جداً! أنفقت ${ratio.toStringAsFixed(0)}% ووفّرت ﷼${savings.toStringAsFixed(0)}. واصل هذا الأداء.';
    } else if (ratio < 70) {
      return 'أنفقت ${ratio.toStringAsFixed(0)}% من دخلك. ممتاز، لكن هناك مجال للتحسين في بعض الفئات.';
    } else if (ratio < 90) {
      return 'تنبيه: أنفقت ${ratio.toStringAsFixed(0)}% من دخلك. راجع مصاريفك لتحسين معدل الادخار.';
    } else {
      return 'تحذير: أنفقت ${ratio.toStringAsFixed(0)}% من دخلك! حان وقت مراجعة الميزانية بشكل جدي.';
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  BEHAVIOR DETECTION (Enhanced)
  // ══════════════════════════════════════════════════════════════════

  List<Recommendation> detectRepeatedBehaviors({
    required double income,
    required double expenses,
    required List<Expense> recentExpenses,
    required Map<String, double> categoryTotals,
  }) {
    final recommendations = <Recommendation>[];
    final now = DateTime.now();
    int priority = 10;

    if (recentExpenses.length < 3) return recommendations;

    // ── Frequent purchase detection ──
    final categoryCount = <String, int>{};
    for (final exp in recentExpenses) {
      categoryCount[exp.category] = (categoryCount[exp.category] ?? 0) + 1;
    }

    for (final entry in categoryCount.entries) {
      if (entry.value >= 5 && categoryTotals[entry.key] != null) {
        final total = categoryTotals[entry.key]!;
        final arabicName = _arabicCategory[entry.key] ?? entry.key;
        recommendations.add(Recommendation(
          id: 'frequent_${entry.key}',
          message: 'قمت بـ ${entry.value} عملية شراء في "$arabicName" (الإجمالي: ﷼${total.toStringAsFixed(0)}). حدد شهرياً لتجنب الإفراط.',
          category: 'category',
          priority: priority--,
          createdAt: now,
        ));
      }
    }

    // ── Overspending category detection ──
    if (expenses > 0) {
      for (final entry in categoryTotals.entries) {
        final percent = (entry.value / expenses) * 100;
        if (percent > 40) {
          final arabicName = _arabicCategory[entry.key] ?? entry.key;
          recommendations.add(Recommendation(
            id: 'overspend_${entry.key}',
            message: '"$arabicName" يمثل ${percent.toStringAsFixed(0)}% من مصروفاتك. حاول عدم تجاوز 30% لكل فئة.',
            category: 'budgeting',
            priority: priority--,
            createdAt: now,
          ));
        }
      }
    }

    // ── Consistent saving ──
    if (income > 0) {
      final savingRate = ((income - expenses) / income) * 100;
      if (savingRate >= 20) {
        recommendations.add(Recommendation(
          id: 'consistent_saving',
          message: 'أنت توفر ${savingRate.toStringAsFixed(0)}% من دخلك باستمرار. إنضباط مالي ممتاز!',
          category: 'saving',
          priority: priority--,
          createdAt: now,
        ));
      }
    }

    // ── Missed saving opportunities ──
    if (recentExpenses.length >= 5) {
      final nonEssentialTotal = categoryTotals.entries
          .where((e) => ['Entertainment', 'Shopping', 'Food'].contains(e.key))
          .fold<double>(0, (sum, e) => sum + e.value);

      if (nonEssentialTotal > income * 0.3) {
        final potentialSaving = (nonEssentialTotal * 0.2).toStringAsFixed(0);
        recommendations.add(Recommendation(
          id: 'missed_savings',
          message: 'المصروفات غير الضرورية (طعام، تسوق، ترفيه) ﷼${nonEssentialTotal.toStringAsFixed(0)}. خفضها بنسبة 20% يوفر ﷼$potentialSaving.',
          category: 'saving',
          priority: priority--,
          createdAt: now,
        ));
      }
    }

    // ── Unusual large transactions ──
    if (recentExpenses.isNotEmpty) {
      final avg = recentExpenses.fold<double>(0, (s, e) => s + e.amount) / recentExpenses.length;
      for (final exp in recentExpenses) {
        if (exp.amount > avg * 3 && exp.amount > 500) {
          recommendations.add(Recommendation(
            id: 'unusual_${exp.id ?? exp.date.millisecondsSinceEpoch}',
            message: 'لاحظنا معاملة كبيرة غير معتادة بقيمة ﷼${exp.amount.toStringAsFixed(0)} في "${_arabicCategory[exp.category] ?? exp.category}". تأكد من أن هذا المصروف كان مقصوداً.',
            category: 'unusual',
            priority: priority--,
            createdAt: now,
          ));
          break;
        }
      }
    }

    return recommendations;
  }

  // ══════════════════════════════════════════════════════════════════
  //  GOAL-AWARE BEHAVIOR DETECTION
  // ══════════════════════════════════════════════════════════════════

  List<Recommendation> detectGoalBehaviors({
    required double income,
    required double expenses,
    required List<FinancialGoal> goals,
    required Map<String, double> categoryTotals,
  }) {
    final recommendations = <Recommendation>[];
    final now = DateTime.now();
    int priority = 10;

    if (income <= 0 || goals.isEmpty) return recommendations;

    final savings = income - expenses;
    final activeGoals = goals.where((g) => !g.isCompleted).toList();

    for (final goal in activeGoals) {
      if (goal.daysRemaining == null || goal.daysRemaining! <= 0) continue;

      final monthsLeft = (goal.daysRemaining! / 30).ceil();
      if (monthsLeft <= 0) continue;

      final neededPerMonth = goal.remaining / monthsLeft;

      // Check if spending in any category could fund the goal
      for (final entry in categoryTotals.entries) {
        final potentialSaving = entry.value * 0.15;
        if (potentialSaving >= neededPerMonth * 0.3) {
          final arabicName = _arabicCategory[entry.key] ?? entry.key;
          final goalPercent = (neededPerMonth / income * 100).toStringAsFixed(0);
          recommendations.add(Recommendation(
            id: 'goal_funding_${goal.id}_${entry.key}',
            message: 'خفض "$arabicName" بنسبة 15% (﷼${potentialSaving.toStringAsFixed(0)}) يمول $goalPercent% من هدف "${goal.title}" شهرياً.',
            category: 'goals',
            priority: priority--,
            createdAt: now,
          ));
        }
      }

      // Check if savings rate is sufficient for goal
      if (savings > 0 && neededPerMonth > 0) {
        final ratio = savings / neededPerMonth;
        if (ratio < 0.8) {
          recommendations.add(Recommendation(
            id: 'goal_pace_${goal.id}',
            message: 'معدل ادخارك الحالي لا يكفي لتحقيق "${goal.title}" في الوقت المحدد. حاول زيادة الادخار بـ ﷼${(neededPerMonth - savings).toStringAsFixed(0)} شهرياً.',
            category: 'goals',
            priority: priority--,
            createdAt: now,
          ));
        } else if (ratio >= 1.0) {
          recommendations.add(Recommendation(
            id: 'goal_on_track_${goal.id}',
            message: 'أنت على المسار الصحيح لإنجاز "${goal.title}"! واصل بنفس الوتيرة.',
            category: 'achievements',
            priority: priority--,
            createdAt: now,
          ));
        }
      }
    }

    return recommendations;
  }

  // ══════════════════════════════════════════════════════════════════
  //  SPENDING PATTERN (Enhanced)
  // ══════════════════════════════════════════════════════════════════

  String detectSpendingPattern(Map<String, double> categoryTotals, double total) {
    if (total == 0) return 'لم يتم تسجيل أي مصروفات بعد. ابدأ بإضافة مصروفاتك!';

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) return 'توزيع المصروفات يبدو متوازناً.';

    final topCategory = entries.first;
    final percent = (topCategory.value / total) * 100;
    final arabicName = _arabicCategory[topCategory.key] ?? topCategory.key;

    if (percent > 40) {
      return '$arabicName يشكل ${percent.toStringAsFixed(0)}% من إجمالي مصروفاتك — حاول التنويع.';
    }
    return 'توزيع المصروفات يبدو متوازناً.';
  }
}

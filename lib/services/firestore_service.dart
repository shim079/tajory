import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/activity_log.dart';
import '../models/badge.dart';
import '../models/expense.dart';
import '../models/financial_goal.dart';
import '../models/habit.dart';

import '../models/island_state.dart';
import '../models/recommendation.dart';
import '../models/reward.dart';
import '../models/savings_record.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference _userRef(String uid) =>
      _firestore.collection('users').doc(uid);

  // ─── User Profile ────────────────────────────────────────────────

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    double income = 0,
    String salaryDate = '',
    List<String>? financialGoals,
    String? selectedCompanion,
    String? bankStatementUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'income': income,
        'salaryDate': salaryDate,
        'financialGoals': financialGoals ?? [],
        'selectedPet': selectedCompanion ?? '',
        'bankStatementUrl': bankStatementUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'setupComplete': true,
      });
    } catch (e) {
      debugPrint('FirestoreService.createUser error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      debugPrint('FirestoreService.getUserProfile error: $e');
      rethrow;
    }
  }

  Future<void> updateUserIncome({
    required String uid,
    required double income,
    String? salaryDate,
  }) async {
    try {
      final data = <String, dynamic>{'income': income};
      if (salaryDate != null) data['salaryDate'] = salaryDate;
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('FirestoreService.updateUserIncome error: $e');
      rethrow;
    }
  }

  // ─── Expenses ────────────────────────────────────────────────────

  Future<void> addExpense({
    required String uid,
    required double amount,
    required String category,
    String description = '',
    String source = 'manual',
  }) async {
    try {
      final stdCategory = Expense.standardizeCategory(category);
      await _userRef(uid).collection('expenses').add({
        'amount': amount,
        'category': stdCategory,
        'description': description,
        'source': source,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FirestoreService.addExpense error: $e');
      rethrow;
    }
  }

  Future<List<Expense>> getExpenses(String uid) async {
    try {
      final snapshot = await _userRef(uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Expense.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('FirestoreService.getExpenses error: $e');
      rethrow;
    }
  }

  Future<double> calculateTotalExpenses(String uid) async {
    try {
      final snapshot =
          await _userRef(uid).collection('expenses').get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = data['amount'];
        if (amount is num) {
          total += amount.toDouble();
        }
      }
      return total;
    } catch (e) {
      debugPrint('FirestoreService.calculateTotalExpenses error: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> getExpensesByCategory(String uid) async {
    try {
      final snapshot =
          await _userRef(uid).collection('expenses').get();

      final categories = <String, double>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String? ?? 'Other';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        categories[category] =
            (categories[category] ?? 0) + amount;
      }
      return categories;
    } catch (e) {
      debugPrint('FirestoreService.getExpensesByCategory error: $e');
      rethrow;
    }
  }

  Future<int> getExpenseCount(String uid) async {
    try {
      final snapshot =
          await _userRef(uid).collection('expenses').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('FirestoreService.getExpenseCount error: $e');
      return 0;
    }
  }

  // ─── Goals ───────────────────────────────────────────────────────

  Future<void> addGoal({
    required String uid,
    required String title,
    required double target,
    DateTime? deadline,
  }) async {
    try {
      await _userRef(uid).collection('goals').add({
        'title': title,
        'target': target,
        'saved': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'deadline': deadline?.toIso8601String(),
        'completedAt': null,
        'isCompleted': false,
      });
    } catch (e) {
      debugPrint('FirestoreService.addGoal error: $e');
      rethrow;
    }
  }

  Future<List<FinancialGoal>> getGoals(String uid) async {
    try {
      final snapshot = await _userRef(uid)
          .collection('goals')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return FinancialGoal.fromMap(doc.data(), id: doc.id);
      }).toList();
    } catch (e) {
      debugPrint('FirestoreService.getGoals error: $e');
      rethrow;
    }
  }

  Future<void> updateGoalSaved({
    required String uid,
    required String goalId,
    required double saved,
  }) async {
    try {
      await _userRef(uid).collection('goals').doc(goalId).update({
        'saved': saved,
      });
    } catch (e) {
      debugPrint('FirestoreService.updateGoalSaved error: $e');
      rethrow;
    }
  }

  Future<void> completeGoal({
    required String uid,
    required String goalId,
  }) async {
    try {
      await _userRef(uid).collection('goals').doc(goalId).update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FirestoreService.completeGoal error: $e');
      rethrow;
    }
  }

  // ─── Savings Records ─────────────────────────────────────────────

  Future<void> addSavingsRecord({
    required String uid,
    required double amount,
    String? notes,
    String? goalId,
  }) async {
    try {
      await _userRef(uid).collection('savings').add({
        'amount': amount,
        'notes': notes ?? '',
        'date': FieldValue.serverTimestamp(),
        'goalId': goalId ?? '',
      });
    } catch (e) {
      debugPrint('FirestoreService.addSavingsRecord error: $e');
      rethrow;
    }
  }

  Future<List<SavingsRecord>> getSavingsRecords(String uid) async {
    try {
      final snapshot = await _userRef(uid)
          .collection('savings')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SavingsRecord.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('FirestoreService.getSavingsRecords error: $e');
      return [];
    }
  }

  Future<double> calculateTotalSaved(String uid) async {
    try {
      final snapshot = await _userRef(uid).collection('savings').get();
      double total = 0;
      for (var doc in snapshot.docs) {
        final amount = doc.data()['amount'];
        if (amount is num) total += amount.toDouble();
      }
      return total;
    } catch (e) {
      debugPrint('FirestoreService.calculateTotalSaved error: $e');
      return 0;
    }
  }

  // ─── Habits ──────────────────────────────────────────────────────

  Future<void> setHabit({
    required String uid,
    required Habit habit,
  }) async {
    try {
      await _userRef(uid).collection('habits').doc(habit.type.name).set(
        habit.toMap(),
      );
    } catch (e) {
      debugPrint('FirestoreService.setHabit error: $e');
      rethrow;
    }
  }

  Future<Habit?> getActiveHabit(String uid) async {
    try {
      final snapshot =
          await _userRef(uid).collection('habits').limit(1).get();

      if (snapshot.docs.isEmpty) return null;
      return Habit.fromMap(snapshot.docs.first.data(),
          id: snapshot.docs.first.id);
    } catch (e) {
      debugPrint('FirestoreService.getActiveHabit error: $e');
      return null;
    }
  }

  Future<void> logHabitCheckin({
    required String uid,
    required String habitType,
  }) async {
    try {
      final today = DateTime.now();
      final dayStart = DateTime(today.year, today.month, today.day);
      await _userRef(uid).collection('habitProgress').add({
        'habitType': habitType,
        'date': dayStart.toIso8601String(),
        'completed': true,
      });
    } catch (e) {
      debugPrint('FirestoreService.logHabitCheckin error: $e');
      rethrow;
    }
  }

  Future<bool> hasCheckedInToday({
    required String uid,
    required String habitType,
  }) async {
    try {
      final today = DateTime.now();
      final dayStart = DateTime(today.year, today.month, today.day);

      final snapshot = await _userRef(uid)
          .collection('habitProgress')
          .where('habitType', isEqualTo: habitType)
          .where('date', isEqualTo: dayStart.toIso8601String())
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('FirestoreService.hasCheckedInToday error: $e');
      return false;
    }
  }

  Future<int> getHabitStreak({
    required String uid,
    required String habitType,
  }) async {
    try {
      final snapshot = await _userRef(uid)
          .collection('habitProgress')
          .where('habitType', isEqualTo: habitType)
          .orderBy('date', descending: true)
          .get();

      final dates = snapshot.docs.map((doc) {
        final dateStr = doc.data()['date'] as String;
        return DateTime.parse(dateStr);
      }).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

      if (dates.isEmpty) return 0;

      int streak = 0;
      final today = DateTime.now();
      final checkDate = DateTime(today.year, today.month, today.day);

      for (final d in dates) {
        final dateDay = DateTime(d.year, d.month, d.day);
        final diff = checkDate.difference(dateDay).inDays;
        if (diff == streak) {
          streak++;
        } else if (diff > streak) {
          break;
        }
      }

      return streak;
    } catch (e) {
      debugPrint('FirestoreService.getHabitStreak error: $e');
      return 0;
    }
  }

  // ─── Activity Log ────────────────────────────────────────────────

  Future<void> logActivity({
    required String uid,
    required String action,
    required String description,
    int xpEarned = 0,
  }) async {
    try {
      await _userRef(uid).collection('activityLog').add({
        'action': action,
        'description': description,
        'xpEarned': xpEarned,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FirestoreService.logActivity error: $e');
    }
  }

  Future<List<ActivityLog>> getActivityLog(String uid, {int limit = 50}) async {
    try {
      final snapshot = await _userRef(uid)
          .collection('activityLog')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ActivityLog.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('FirestoreService.getActivityLog error: $e');
      return [];
    }
  }

  // ─── Badges ──────────────────────────────────────────────────────

  Future<void> unlockBadge({
    required String uid,
    required Badge badge,
  }) async {
    try {
      await _userRef(uid).collection('badges').doc(badge.id).set(
        badge.toMap(),
      );
    } catch (e) {
      debugPrint('FirestoreService.unlockBadge error: $e');
    }
  }

  Future<List<Badge>> getUnlockedBadges(String uid) async {
    try {
      final snapshot = await _userRef(uid).collection('badges').get();
      return snapshot.docs
          .map((doc) => Badge.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('FirestoreService.getUnlockedBadges error: $e');
      return [];
    }
  }

  Future<Set<String>> getUnlockedBadgeIds(String uid) async {
    try {
      final snapshot = await _userRef(uid).collection('badges').get();
      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      debugPrint('FirestoreService.getUnlockedBadgeIds error: $e');
      return {};
    }
  }

  // ─── Island State ────────────────────────────────────────────────

  Future<void> saveIslandState({
    required String uid,
    required IslandState state,
  }) async {
    try {
      await _userRef(uid).collection('island').doc('state').set(
        state.toMap(),
      );
    } catch (e) {
      debugPrint('FirestoreService.saveIslandState error: $e');
      rethrow;
    }
  }

  Future<IslandState> getIslandState(String uid) async {
    try {
      final doc =
          await _userRef(uid).collection('island').doc('state').get();

      if (!doc.exists) return IslandState();
      return IslandState.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('FirestoreService.getIslandState error: $e');
      return IslandState();
    }
  }

  // ─── Rewards ─────────────────────────────────────────────────────

  Future<void> addReward({
    required String uid,
    required Reward reward,
  }) async {
    try {
      await _userRef(uid).collection('rewards').doc(reward.id).set(
        reward.toMap(),
      );
    } catch (e) {
      debugPrint('FirestoreService.addReward error: $e');
      rethrow;
    }
  }

  Future<List<Reward>> getRewards(String uid) async {
    try {
      final snapshot = await _userRef(uid)
          .collection('rewards')
          .orderBy('unlockedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Reward.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('FirestoreService.getRewards error: $e');
      return [];
    }
  }

  Future<void> markRewardSeen({
    required String uid,
    required String rewardId,
  }) async {
    try {
      await _userRef(uid).collection('rewards').doc(rewardId).update({
        'isNew': false,
      });
    } catch (e) {
      debugPrint('FirestoreService.markRewardSeen error: $e');
    }
  }

  // ─── Recommendations ─────────────────────────────────────────────

  Future<void> saveRecommendations({
    required String uid,
    required List<Recommendation> recommendations,
  }) async {
    try {
      final batch = _firestore.batch();
      final ref = _userRef(uid).collection('recommendations');

      for (final rec in recommendations) {
        batch.set(ref.doc(rec.id), rec.toMap());
      }
      await batch.commit();
    } catch (e) {
      debugPrint('FirestoreService.saveRecommendations error: $e');
      rethrow;
    }
  }

  Future<List<Recommendation>> getRecommendations(String uid) async {
    try {
      final snapshot = await _userRef(uid)
          .collection('recommendations')
          .orderBy('priority', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Recommendation.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('FirestoreService.getRecommendations error: $e');
      return [];
    }
  }

  // ─── Calculations ────────────────────────────────────────────────

  Future<double> calculateTotalSavings(String uid, double income) async {
    try {
      final expenses = await calculateTotalExpenses(uid);
      return income - expenses;
    } catch (e) {
      debugPrint('FirestoreService.calculateTotalSavings error: $e');
      rethrow;
    }
  }

  Future<double> getSavingRate(String uid, double income) async {
    try {
      final expenses = await calculateTotalExpenses(uid);
      if (income == 0) return 0;
      return ((income - expenses) / income) * 100;
    } catch (e) {
      debugPrint('FirestoreService.getSavingRate error: $e');
      rethrow;
    }
  }

  // ─── Daily Check-In ──────────────────────────────────────────────

  Future<Map<String, dynamic>?> getDailyCheckIn(String uid) async {
    try {
      final doc = await _userRef(uid).collection('daily_checkin').doc('state').get();
      return doc.data();
    } catch (e) {
      debugPrint('FirestoreService.getDailyCheckIn error: $e');
      return null;
    }
  }

  Future<void> performDailyCheckIn(String uid) async {
    try {
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);
      final todayStr = todayNormalized.toIso8601String();

      final doc = await _userRef(uid).collection('daily_checkin').doc('state').get();
      final data = doc.data();

      int currentStreak = data?['currentStreak'] as int? ?? 0;
      final lastCheckInStr = data?['lastCheckIn'] as String?;
      final checkedDays = List<String>.from(data?['checkedDays'] as List<dynamic>? ?? []);

      if (lastCheckInStr != null) {
        final lastCheckIn = DateTime.parse(lastCheckInStr);
        final lastNormalized = DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day);
        final diff = todayNormalized.difference(lastNormalized).inDays;

        if (diff == 0) {
          if (checkedDays.contains(todayStr)) return;
        } else if (diff == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      } else {
        currentStreak = 1;
      }

      if (!checkedDays.contains(todayStr)) {
        checkedDays.add(todayStr);
      }

      await _userRef(uid).collection('daily_checkin').doc('state').set({
        'currentStreak': currentStreak,
        'lastCheckIn': todayStr,
        'checkedDays': checkedDays,
      });
    } catch (e) {
      debugPrint('FirestoreService.performDailyCheckIn error: $e');
      rethrow;
    }
  }
}

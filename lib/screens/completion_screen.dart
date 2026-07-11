import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/reward.dart';
import 'home_screen.dart';

class CompletionScreen extends StatefulWidget {
  const CompletionScreen({super.key});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with SingleTickerProviderStateMixin {
  final firestoreService = FirestoreService();
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool isLoading = true;
  String? rewardTitle;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.5, 1.0)),
    );
    _initReward();
  }

  Future<void> _initReward() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final goals = await firestoreService.getGoals(user.uid);
      final completedGoals = goals.where((g) => g.isCompleted).toList();
      final goalCount = completedGoals.length;

      final reward = Reward(
        id: 'goal_${goalCount}_${DateTime.now().millisecondsSinceEpoch}',
        title: goalCount == 1
            ? 'First Goal Achieved!'
            : 'Goal #$goalCount Completed!',
        description: goalCount == 1
            ? 'You\'ve reached your first financial goal! Your island is growing.'
            : 'Another goal crushed! Keep building your financial future.',
        iconAsset: goalCount >= 5 ? 'trophy' : 'star',
      );

      final state = await firestoreService.getIslandState(user.uid);
      final evolved = state.evolve(100);
      await firestoreService.saveIslandState(uid: user.uid, state: evolved);
      await firestoreService.addReward(uid: user.uid, reward: reward);

      if (!mounted) return;
      setState(() => rewardTitle = reward.title);
    } catch (e) {
      setState(() => rewardTitle = 'Goal Completed!');
    } finally {
      if (mounted) setState(() => isLoading = false);
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() => isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final rewards = await firestoreService.getRewards(user.uid);
      for (final r in rewards.where((r) => r.isNew)) {
        await firestoreService.markRewardSeen(uid: user.uid, rewardId: r.id);
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _scaleAnim,
                          builder: (context, child) => Transform.scale(
                            scale: _scaleAnim.value,
                            child: child,
                          ),
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primaryContainer,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        AnimatedBuilder(
                          animation: _fadeAnim,
                          builder: (context, child) => Opacity(
                            opacity: _fadeAnim.value,
                            child: child,
                          ),
                          child: Column(
                            children: [
                              Text(
                                rewardTitle ?? 'Congratulations!',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'You\'ve reached your financial goal!\n'
                                'Your island has evolved and a new reward awaits.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.stars_rounded,
                                          color: Colors.amber.shade600, size: 32),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Island Level Up!',
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.w600)),
                                          Text('+100 XP earned',
                                              style: theme.textTheme.bodySmall),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              FilledButton.icon(
                                onPressed: isSaving ? null : _continue,
                                icon: isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.arrow_forward),
                                label: const Text('Continue to Dashboard'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

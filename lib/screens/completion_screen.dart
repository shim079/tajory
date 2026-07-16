import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/reward.dart';
import 'home_screen.dart';

class CompletionScreen extends StatefulWidget {
  final String title;
  final String message;
  final bool needsReward;

  const CompletionScreen({
    super.key,
    this.title = 'Congratulations!',
    this.message = 'You\'ve reached your financial goal!\n'
        'Your island has evolved and a new reward awaits.',
    this.needsReward = true,
  });

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
    if (widget.needsReward) {
      _initReward();
    } else {
      setState(() => isLoading = false);
      _animController.forward();
    }
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
            ? 'الهدف الأول تحقق!'
        : 'الهدف  #$goalCount اكتمل! ',
        description: goalCount == 1
            ? 'You\'ve reached your first financial goal! Your island is growing.'
            : 'هدف آخر تحقق! استمر في بناء مستقبلك المالي.',
        iconAsset: goalCount >= 5 ? 'trophy' : 'star',
      );

      final state = await firestoreService.getIslandState(user.uid);
      final evolved = state.evolve(100);
      await firestoreService.saveIslandState(uid: user.uid, state: evolved);
      await firestoreService.addReward(uid: user.uid, reward: reward);

      if (!mounted) return;
      setState(() => rewardTitle = reward.title);
    } catch (e) {
      setState(() => rewardTitle = 'تم إنجاز الهدف!');
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
    if (!widget.needsReward) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return;
    }
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
    final size = MediaQuery.of(context).size;
    final sandHeight = size.height * 0.14;
    final iconSize = size.width * 0.51;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/fullbg.png',
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: sandHeight,
            child: Image.asset(
              'assets/images/sand.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          SafeArea(
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
                            child: SvgPicture.asset(
                              'assets/images/Feedback Icon.svg',
                              width: iconSize,
                              height: iconSize,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _fadeAnim,
                            builder: (context, child) => Opacity(
                              opacity: _fadeAnim.value,
                              child: child,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.message,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 32),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: FilledButton.icon(
                                  onPressed: isSaving ? null : _continue,
                                  icon: isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.arrow_back),
                                  label: const Text('انتقل الى واحتي'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32), // #2E7D32
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.27, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    )
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
        ],
      ),
    );
  }
}

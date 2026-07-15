import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/financial_goal.dart';
import '../models/island_state.dart';
import '../services/firestore_service.dart';
import '../services/pet_service.dart';
import '../widgets/advisor_recommendation_card.dart';

import '../widgets/profile_header.dart';

class IslandScreen extends StatefulWidget {
  const IslandScreen({super.key});

  @override
  State<IslandScreen> createState() => _IslandScreenState();
}

class _IslandScreenState extends State<IslandScreen> {
  final _firestoreService = FirestoreService();

  IslandState? _islandState;
  String? _companionAsset;
  bool _isLoading = true;
  String? _error;
  String? _adviceTitle;
  String? _adviceMessage;
  List<FinancialGoal> _goals = [];

  static const _goalEmojis = {
    'Home': '\u{1F3E0}',
    'Education': '\u{1F4DA}',
    'Travel': '\u{1F9F3}',
    'Car': '\u{1F697}',
    'Marriage': '\u{1F48D}',
    'Emergencies': '\u{1F3E6}',
    'New Device': '\u{1F4BB}',
    'Other': '\u{1F4B0}',
  };

  static const _companionMap = {
    'Home 1': 'home 1.png',
    'Home 2': 'home 2.png',
    'Home 3': 'home 3.png',
    'Home 4': 'home 4.png',
  };

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'Not logged in';
        });
        return;
      }

      final results = await Future.wait([
        _firestoreService.getIslandState(user.uid),
        _firestoreService.getUserProfile(user.uid),
        _firestoreService.getGoals(user.uid),
      ]);

      final islandState = results[0] as IslandState;
      final profile = results[1] as Map<String, dynamic>?;
      final goals = results[2] as List<FinancialGoal>;
      final selectedPet = profile?['selectedPet'] as String?;
      final companionAsset = PetService.getCompanionAssetPath(selectedPet);

      if (!mounted) return;
      setState(() {
        _islandState = islandState;
        _companionAsset = companionAsset;
        _adviceTitle = profile?['adviceTitle'] as String?;
        _adviceMessage = profile?['adviceMessage'] as String?;
        _goals = goals;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }

    _loadCompanion();
  }

  Future<void> _loadCompanion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profile = await _firestoreService.getUserProfile(user.uid);
    if (profile == null) return;

    final selectedPet = profile['selectedPet'] as String? ?? '';
    final asset = _companionMap[selectedPet] ?? 'home 1.png';

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _companionAsset = asset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bsckground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const ProfileHeader(),
            if (_adviceTitle != null && _adviceMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: AdvisorRecommendationCard(
                    avatarAsset: 'assets/images/advisor.png',
                    title: _adviceTitle!,
                    message: _adviceMessage!,
                    compact: true,
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: _companionAsset == null
                    ? const CircularProgressIndicator()
                    : Image.asset(
                        'assets/images/${_companionAsset!}',
                        width: 200,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            if (_goals.isNotEmpty)
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: _buildGoalsCard(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Center(
          child: _companionAsset != null
              ? Image.asset(
                  _companionAsset!,
                  width: 350,
                  height: 525,
                )
              : Image.asset(
                  'assets/images/camel.png',
                  width: 350,
                  height: 525,
                ),
        ),
        if (_islandState != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildIslandInfoCard(_islandState!),
          ),
      ],
    );
  }

  Widget _buildIslandInfoCard(IslandState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.landscape_rounded,
                  color: Colors.green.shade700, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.description,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.levelProgress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${state.level}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${state.points} / ${state.pointsToNextLevel} XP',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.lock_open_rounded,
                  size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Text(
                '${state.unlockedFeatures.length} features unlocked',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(state.lastUpdated),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildGoalsCard() {
    final theme = Theme.of(context);
    final active = _goals.where((g) => !g.isCompleted).toList();

    if (active.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
          children: [
            Icon(Icons.flag_rounded, color: Colors.green.shade700, size: 18),
            const SizedBox(width: 8),
            Text(
              'ليس لديك أهداف بعد. حدد هدفك الآن!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF222222),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    active.sort((a, b) {
      final aProgress = a.progressPercent;
      final bProgress = b.progressPercent;
      if (aProgress >= 1 && bProgress >= 1) return 0;
      if (aProgress >= 1) return 1;
      if (bProgress >= 1) return -1;
      return bProgress.compareTo(aProgress);
    });
    final nearest = active.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              'أنت تقترب من هدفك!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF222222),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${_goalEmojis[nearest.goalType] ?? '\u{1F4B0}'} ${nearest.title}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,

              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '﷼${nearest.saved.toStringAsFixed(0)} من ﷼${nearest.target.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: SizedBox(
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: nearest.progressPercent,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

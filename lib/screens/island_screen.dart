import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/island_state.dart';
import '../services/firestore_service.dart';
import '../services/pet_service.dart';
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
      ]);

      final islandState = results[0] as IslandState;
      final profile = results[1] as Map<String, dynamic>?;
      final selectedPet = profile?['selectedPet'] as String?;
      final companionAsset = PetService.getCompanionAssetPath(selectedPet);

      if (!mounted) return;
      setState(() {
        _islandState = islandState;
        _companionAsset = companionAsset;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
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
            Expanded(
              child: _buildBody(),
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
}

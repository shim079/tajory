import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/user_level.dart';
import '../services/firestore_service.dart';

class UserIslandScreen extends StatefulWidget {
  final String uid;
  final String userName;
  final String? profileImage;

  const UserIslandScreen({
    super.key,
    required this.uid,
    required this.userName,
    this.profileImage,
  });

  @override
  State<UserIslandScreen> createState() => _UserIslandScreenState();
}

class _UserIslandScreenState extends State<UserIslandScreen> {
  final _firestoreService = FirestoreService();
  int _totalXP = 0;
  bool _isLoading = true;
  String? _companionAsset;

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
    _loadCompanion();
  }

  Future<void> _loadData() async {
    final stats = await _firestoreService.getUserLeaderboardStats(widget.uid);
    final savingsDays = stats['savingsDays'] as int;
    final checkedDays = stats['checkedDays'] as int;
    final savingsCount = stats['savingsCount'] as int;
    final streak = stats['currentStreak'] as int;
    final savingScore = (savingsDays * 10) + (savingsCount * 20);
    final attendanceScore = (checkedDays * 5) + (streak * 10);

    if (!mounted) return;
    setState(() {
      _totalXP = savingScore + attendanceScore;
      _isLoading = false;
    });
  }

  Future<void> _loadCompanion() async {
    final profile = await _firestoreService.getUserProfile(widget.uid);
    if (profile == null) return;

    final selectedPet = profile['selectedPet'] as String? ?? '';
    final asset = _companionMap[selectedPet] ?? 'home 1.png';

    if (!mounted) return;
    setState(() => _companionAsset = asset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userLevel = calculateUserLevel(_totalXP);
    final hasImage = widget.profileImage != null && widget.profileImage!.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5EF),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/userBG.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 70, left: 24, right: 24, bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'جزيرة ${widget.userName}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_forward_ios_rounded, size: 19, color: Colors.grey.shade700),
                        ),
                        const SizedBox(width: 16),
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: hasImage ? NetworkImage(widget.profileImage!) : null,
                          child: hasImage
                              ? null
                              : ClipOval(
                                  child: Image.asset(
                                    'assets/images/image.png',
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/level.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    userLevel.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$_totalXP XP',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Align(
                       alignment: Alignment(0, 1.3),
                       child: FractionallySizedBox(
                         widthFactor: 0.65,  // 85% of available width
                         heightFactor: 0.75,
                         child: Image.asset(
                          'assets/images/${_companionAsset ?? 'camel.png'}',
                          fit: BoxFit.contain,
                         ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

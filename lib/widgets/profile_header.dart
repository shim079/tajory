import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/island_state.dart';
import '../models/user_level.dart';
import '../services/firestore_service.dart';

class ProfileHeader extends StatefulWidget {
  final VoidCallback? onAvatarTap;
  final bool showLevelInfo;

  const ProfileHeader({super.key, this.onAvatarTap, this.showLevelInfo = false});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();

  String _userName = '';
  String? _profileImageUrl;
  int _currentLevel = 1;
  int _currentXP = 0;
  int _requiredXP = 100;
  bool _isLoading = true;
  int currentStreak = 0;
  int _totalXP = 0;

  int _currentStreak = 0;
  List<DateTime> _checkedDays = [];
  bool _hasCheckedInToday = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _loadAllData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final profileFuture = _firestoreService.getUserProfile(user.uid);
      final islandFuture = _firestoreService.getIslandState(user.uid);
      final checkInFuture = _firestoreService.getDailyCheckIn(user.uid);
      final statsFuture = _firestoreService.getUserLeaderboardStats(user.uid);

      final results =
          await Future.wait([profileFuture, islandFuture, checkInFuture, statsFuture]);

      final profile = results[0] as Map<String, dynamic>?;
      final islandState = results[1] as IslandState;
      final checkInData = results[2] as Map<String, dynamic>?;
      final stats = results[3] as Map<String, dynamic>;

      if (!mounted) return;

      final checkedDaysRaw =
          checkInData?['checkedDays'] as List<dynamic>? ?? [];
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);

      final userName = profile?['name'] as String? ?? user.displayName ?? 'User';
      final profileImageUrl = profile?['profileImage'] as String?;
      final currentLevel = islandState.level;
      final currentXP = islandState.points;
      final requiredXP = islandState.pointsToNextLevel;
      final currentStreak = checkInData?['currentStreak'] as int? ?? 0;
      final checkedDays =
          checkedDaysRaw.map((d) => DateTime.parse(d as String)).toList();
      final hasCheckedInToday = checkedDays.any((d) =>
          d.year == today.year &&
          d.month == today.month &&
          d.day == today.day);

      final savingsDays = stats['savingsDays'] as int;
      final checkedDaysCount = stats['checkedDays'] as int;
      final savingsCount = stats['savingsCount'] as int;
      final streak = stats['currentStreak'] as int;
      final savingScore = (savingsDays * 10) + (savingsCount * 20);
      final attendanceScore = (checkedDaysCount * 5) + (streak * 10);
      final totalXP = savingScore + attendanceScore;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _userName = userName;
          _profileImageUrl = profileImageUrl;
          _currentLevel = currentLevel;
          _currentXP = currentXP;
          _requiredXP = requiredXP;
          _currentStreak = currentStreak;
          _checkedDays = checkedDays;
          _hasCheckedInToday = hasCheckedInToday;
          _totalXP = totalXP;
          _isLoading = false;
        });
      });
    } catch (e) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }

  String _getFirstName() {
    if (_userName.isEmpty) return '';
    return _userName.trim().split(RegExp(r'\s+')).first;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final firstName = _getFirstName();

    if (hour >= 5 && hour < 12) {
      return 'صباخ الخير, $firstName 👋';
    } else if (hour >= 12 && hour < 17) {
      return 'مساء الخير, $firstName ☀️';
    } else {
      return 'مساء الخير, $firstName 🌙';
    }
  }

  List<DateTime> _getCurrentWeekDays() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final fridayOffset = weekday >= 5 ? weekday - 5 : weekday + 2;
    final friday = now.subtract(Duration(days: fridayOffset));

    return List.generate(7, (i) {
      final day = friday.add(Duration(days: i));
      return DateTime(day.year, day.month, day.day);
    });
  }

  bool _isCompleted(DateTime day) {
    return _checkedDays.any(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day);
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  bool _isFuture(DateTime day) {
    final now = DateTime.now();
    return day.isAfter(DateTime(now.year, now.month, now.day));
  }

  String _dayAbbreviation(DateTime day) {
    const days = ['الاثنين', 'الثلاثاء', 'الارببعاء', 'الخميس', 'الجمعة', 'السبت', 'الاحد'];
    return days[day.weekday - 1];
  }

  Future<void> _onCheckIn() async {
    if (_hasCheckedInToday) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _firestoreService.performDailyCheckIn(user.uid);
      _animController.forward(from: 0);
      await _loadAllData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-in failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: const Color(0xFFF8F5EF),
        padding: widget.showLevelInfo
            ? const EdgeInsets.only(top: 54, bottom: 12)
            : const EdgeInsets.only(left: 20, right: 20, top: 54, bottom: 12),
        child: _isLoading
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : widget.showLevelInfo
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildAvatar(theme),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildLevelInfo(theme),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            'التسجيل اليومي',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _getCurrentWeekDays().map((day) {
                          final completed = _isCompleted(day);
                          final today = _isToday(day);

                          return GestureDetector(
                            onTap: today && !completed ? _onCheckIn : null,
                            child: Column(
                              children: [
                                Text(
                                  _dayAbbreviation(day),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ScaleTransition(
                                  scale: (today && completed)
                                      ? _scaleAnimation
                                      : const AlwaysStoppedAnimation(1.0),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: completed
                                          ? const Color(0xFFFFE8E0)
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: completed
                                            ? Colors.red.shade400
                                            : today
                                                ? Colors.black87
                                                : Colors.grey.shade300,
                                        width: today && !completed ? 2 : 1.5,
                                      ),
                                    ),
                                    child: completed
                                        ? Icon(
                                            Icons.local_fire_department_rounded,
                                            color: Colors.red.shade400,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )
              : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildAvatar(theme),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGreeting(theme),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'التسجيل اليومي',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _getCurrentWeekDays().map((day) {
                          final completed = _isCompleted(day);
                          final today = _isToday(day);

                          return GestureDetector(
                            onTap: today && !completed ? _onCheckIn : null,
                            child: Column(
                              children: [
                                Text(
                                  _dayAbbreviation(day),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ScaleTransition(
                                  scale: (today && completed)
                                      ? _scaleAnimation
                                      : const AlwaysStoppedAnimation(1.0),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: completed
                                          ? const Color(0xFFFFE8E0)
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: completed
                                            ? Colors.red.shade400
                                            : today
                                                ? Colors.black87
                                                : Colors.grey.shade300,
                                        width: today && !completed ? 2 : 1.5,
                                      ),
                                    ),
                                    child: completed
                                        ? Icon(
                                            Icons.local_fire_department_rounded,
                                            color: Colors.red.shade400,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildGreeting(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.local_fire_department_rounded,
                color: Colors.orange.shade700, size: 18),
            const SizedBox(width: 4),
            Text(
              '$_currentStreak ايام ',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelInfo(ThemeData theme) {
    final userLevel = calculateUserLevel(_totalXP);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/level.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                userLevel.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: userLevel.progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_totalXP XP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.local_fire_department_rounded,
                color: Colors.orange.shade700, size: 16),
            const SizedBox(width: 4),
            Text(
              '$_currentStreak ايام ',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final hasImage = _profileImageUrl != null && _profileImageUrl!.isNotEmpty;

    final avatar = CircleAvatar(
      radius: 28,
      backgroundColor: theme.colorScheme.primaryContainer,
      backgroundImage: hasImage ? NetworkImage(_profileImageUrl!) : null,
      child: hasImage
          ? null
          : ClipOval(
              child: Image.asset(
                'assets/images/image.png',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
    );

    if (widget.onAvatarTap == null) return avatar;

    return GestureDetector(
      onTap: widget.onAvatarTap,
      child: avatar,
    );
  }
}

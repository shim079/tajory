import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/user_level.dart';
import '../services/firestore_service.dart';
import 'user_island_screen.dart';

class LeaderboardUser {
  final String uid;
  final String name;
  final String? profileImage;
  final int savingsDays;
  final int checkedDays;
  final int savingsCount;
  final int currentStreak;
  final int totalXP;
  final int savingScore;
  final int attendanceScore;

  LeaderboardUser({
    required this.uid,
    required this.name,
    this.profileImage,
    required this.savingsDays,
    required this.checkedDays,
    required this.savingsCount,
    required this.currentStreak,
    required this.totalXP,
    required this.savingScore,
    required this.attendanceScore,
  });
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _firestoreService = FirestoreService();
  List<LeaderboardUser> _leaderboard = [];
  bool _isLoading = true;
  String _currentUserName = '';
  String? _currentUserProfileImage;
  int _currentUserXP = 0;

  String _selectedSavingType = 'الكل';
  String _selectedTimePeriod = 'هذا الشهر';

  static const _savingTypes = ['الكل', 'ادخار مخطط', 'ادخار مالي'];
  static const _timePeriods = [
    'هذا الأسبوع',
    'هذا الشهر',
    'هذا العام',
    'كل الأوقات',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _firestoreService.getUserProfile(user.uid);
      if (!mounted) return;
      setState(() {
        _currentUserName = profile?['name'] as String? ?? user.email ?? '';
        _currentUserProfileImage = profile?['profileImage'] as String?;
      });
    }

    final users = await _firestoreService.getAllUsers();
    if (!mounted) return;

    final List<LeaderboardUser> leaderboard = [];
    for (final userData in users) {
      final uid = userData['uid'] as String;
      final name = userData['name'] as String? ?? 'Unknown';
      final profileImage = userData['profileImage'] as String?;

      final stats = await _firestoreService.getUserLeaderboardStats(uid);

      final savingsDays = stats['savingsDays'] as int;
      final checkedDays = stats['checkedDays'] as int;
      final savingsCount = stats['savingsCount'] as int;
      final currentStreak = stats['currentStreak'] as int;

      final savingScore = (savingsDays * 10) + (savingsCount * 20);
      final attendanceScore = (checkedDays * 5) + (currentStreak * 10);
      final totalXP = savingScore + attendanceScore;

      leaderboard.add(LeaderboardUser(
        uid: uid,
        name: name,
        profileImage: profileImage,
        savingsDays: savingsDays,
        checkedDays: checkedDays,
        savingsCount: savingsCount,
        currentStreak: currentStreak,
        totalXP: totalXP,
        savingScore: savingScore,
        attendanceScore: attendanceScore,
      ));
    }

    leaderboard.sort((a, b) => b.totalXP.compareTo(a.totalXP));

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final currentUser = leaderboard.where((u) => u.uid == currentUid).firstOrNull;

    if (!mounted) return;
    setState(() {
      _leaderboard = leaderboard;
      _currentUserXP = currentUser?.totalXP ?? 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFDF9),
        surfaceTintColor: const Color(0xFFFFFDF9),
        title: Text(
          'المجتمع',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF2E7D32),
                child: _leaderboard.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 80),
                        Icon(Icons.leaderboard_outlined,
                            size: 72, color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text(
                          'لا يوجد مستخدمون بعد',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.only(top: 16, bottom: 32),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildFilters(theme),
                        ),
                        const SizedBox(height: 26),
                        _buildCurrentUserCard(theme),
                        const SizedBox(height: 26),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'الاخرون',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                              ..._leaderboard.asMap().entries.map((entry) {
                                final index = entry.key;
                                final user = entry.value;
                                final rank = index + 1;
                                final isCurrentUser = user.uid ==
                                    FirebaseAuth.instance.currentUser?.uid;
                                final isLast = index == _leaderboard.length - 1;

                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: isCurrentUser
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => UserIslandScreen(
                                                    uid: user.uid,
                                                    userName: user.name,
                                                    profileImage: user.profileImage,
                                                  ),
                                                ),
                                              );
                                            },
                                      child: _buildUserCard(
                                          theme, user, rank, isCurrentUser),
                                    ),
                                    if (!isLast)
                                      Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                        color: Colors.grey.shade100,
                                      ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
              ),
      ),
    );
  }

  Widget _buildCurrentUserCard(ThemeData theme) {
    final hasImage = _currentUserProfileImage != null &&
        _currentUserProfileImage!.isNotEmpty;
    final userLevel = calculateUserLevel(_currentUserXP);

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage:
                hasImage ? NetworkImage(_currentUserProfileImage!) : null,
            child: hasImage
                ? null
                : ClipOval(
                    child: Image.asset(
                      'assets/images/image.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUserName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userLevel.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_currentUserXP XP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: _selectedSavingType,
            items: _savingTypes,
            icon: Icons.savings_outlined,
            onChanged: (val) => setState(() => _selectedSavingType = val!),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDropdown(
            value: _selectedTimePeriod,
            items: _timePeriods,
            icon: Icons.calendar_today_outlined,
            onChanged: (val) => setState(() => _selectedTimePeriod = val!),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: Colors.grey.shade500),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildUserCard(
      ThemeData theme, LeaderboardUser user, int rank, bool isCurrentUser) {
    final hasImage =
        user.profileImage != null && user.profileImage!.isNotEmpty;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              child: rank == 1
                  ? SvgPicture.asset('assets/images/fi.svg', width: 28, height: 28)
                  : rank == 2
                      ? SvgPicture.asset('assets/images/se.svg', width: 28, height: 28)
                      : rank == 3
                          ? SvgPicture.asset('assets/images/th.svg', width: 28, height: 28)
                          : Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$rank',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage:
                  hasImage ? NetworkImage(user.profileImage!) : null,
              child: hasImage
                  ? null
                  : ClipOval(
                      child: Image.asset(
                        'assets/images/image.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      isCurrentUser ? 'أنت' : user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "النقاط: ${user.totalXP} XP",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_service.dart';
import '../models/badge.dart' as badge_model;
import '../models/pet_model.dart';
import '../services/firestore_service.dart';
import '../services/pet_service.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final firestoreService = FirestoreService();
  final petService = PetService();
  final authService = AuthService();

  String name = '';
  String email = '';
  double income = 0;
  String salaryDate = '';
  Pet? pet;
  List<badge_model.Badge> unlockedBadges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final profile = await firestoreService.getUserProfile(user.uid);
      final p = await petService.getSelectedPet(user.uid);
      final badges = await firestoreService.getUnlockedBadges(user.uid);

      if (!mounted) return;
      setState(() {
        name = profile?['name'] as String? ?? user.email ?? '';
        email = user.email ?? '';
        income = (profile?['income'] as num?)?.toDouble() ?? 0;
        salaryDate = profile?['salaryDate'] as String? ?? '';
        pet = p;
        unlockedBadges = badges;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    try {
      await authService.logout();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Future<void> _editIncome() async {
    final controller =
        TextEditingController(text: income.toStringAsFixed(0));
    final dateController = TextEditingController(text: salaryDate);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Income'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Income (\$)',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Salary Date (optional)',
                hintText: 'e.g. 15th',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              if (v == null || v <= 0) return;
              Navigator.pop(context, {
                'income': v,
                'salaryDate': dateController.text.trim(),
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await firestoreService.updateUserIncome(
        uid: user.uid,
        income: result['income'] as double,
        salaryDate: result['salaryDate'] as String?,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Income updated!')),
      );
      loadProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5EF),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFDF9),
          surfaceTintColor: const Color(0xFFFFFDF9),
          elevation: 0,
          title: const Text(
            'حسابي',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ProfileHeader(),
              const SizedBox(height: 24),
              SettingsSection(
                children: [
                  SettingsItem(
                    title: 'المعلومات الشخصية',
                    icon: Icons.person_outline_rounded,
                    onTap: () {},
                  ),
                  SettingsItem(
                    title: 'سياسات الخصوصية',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {},
                  ),
                  SettingsItem(
                    title: 'عن التطبيق',
                    icon: Icons.info_outline_rounded,
                    onTap: () {},
                  ),
                  SettingsItem(
                    title: 'تواصل معنا',
                    icon: Icons.mail_outline_rounded,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

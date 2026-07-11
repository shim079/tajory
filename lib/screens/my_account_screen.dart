import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_service.dart';
import '../models/badge.dart' as badge_model;
import '../models/pet_model.dart';
import '../services/firestore_service.dart';
import '../services/pet_service.dart';

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
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Income ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Income & Salary',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: _editIncome,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _infoRow(theme, 'Monthly Income',
                      '\$${income.toStringAsFixed(0)}', Icons.attach_money),
                  if (salaryDate.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _infoRow(theme, 'Salary Date', salaryDate,
                        Icons.calendar_today),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Companion Pet ──
          if (pet != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(pet!.emoji,
                        style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Companion',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                          const SizedBox(height: 2),
                          Text(pet!.name,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(pet!.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // ── Achievements ──
          if (unlockedBadges.isNotEmpty) ...[
            Text('Achievements',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: unlockedBadges
                  .map((badge) => Chip(
                        avatar: Icon(
                          badge.id.contains('goal')
                              ? Icons.flag
                              : badge.id.contains('expense')
                                  ? Icons.receipt
                                  : badge.id.contains('saving')
                                      ? Icons.savings
                                      : badge.id.contains('island')
                                          ? Icons.landscape
                                          : badge.id.contains('habit')
                                              ? Icons.loop
                                              : Icons.star,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(badge.title,
                            style: const TextStyle(fontSize: 12)),
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // ── Settings ──
          Text('Settings',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Logout'),
              onTap: logout,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _infoRow(
      ThemeData theme, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
        const Spacer(),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

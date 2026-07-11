import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';
import '../services/firestore_service.dart';
import 'pet_selection_screen.dart';

class HabitSelectionScreen extends StatefulWidget {
  const HabitSelectionScreen({super.key});

  @override
  State<HabitSelectionScreen> createState() => _HabitSelectionScreenState();
}

class _HabitSelectionScreenState extends State<HabitSelectionScreen> {
  final firestoreService = FirestoreService();
  Habit? selectedHabit;
  bool isLoading = false;

  Future<void> saveHabit() async {
    if (selectedHabit == null) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await firestoreService.setHabit(uid: user.uid, habit: selectedHabit!);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PetSelectionScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save habit: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Habit'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...Habit.defaults.map(
                (habit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      selectedHabit?.type == habit.type
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selectedHabit?.type == habit.type
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    title: Text(habit.name),
                    subtitle: Text(habit.description),
                    onTap: () => setState(() => selectedHabit = habit),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed:
                    selectedHabit != null && !isLoading ? saveHabit : null,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Start My Journey'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

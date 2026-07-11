import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'habit_selection_screen.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final targetController = TextEditingController();
  final incomeController = TextEditingController();
  final salaryDateController = TextEditingController();
  final firestoreService = FirestoreService();
  bool isLoading = false;
  DateTime? selectedDeadline;

  @override
  void dispose() {
    titleController.dispose();
    targetController.dispose();
    incomeController.dispose();
    salaryDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date != null) setState(() => selectedDeadline = date);
  }

  Future<void> saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final income = double.parse(incomeController.text.trim());

      await firestoreService.updateUserIncome(
        uid: user.uid,
        income: income,
        salaryDate: salaryDateController.text.trim().isEmpty
            ? null
            : salaryDateController.text.trim(),
      );

      await firestoreService.addGoal(
        uid: user.uid,
        title: titleController.text.trim(),
        target: double.parse(targetController.text.trim()),
        deadline: selectedDeadline,
      );

      await firestoreService.logActivity(
        uid: user.uid,
        action: 'create_goal',
        description: 'Set goal: ${titleController.text.trim()}',
        xpEarned: 0,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HabitSelectionScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Goal'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: incomeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Income (\$)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your monthly income.';
                    }
                    final v = double.tryParse(value.trim());
                    if (v == null || v <= 0) {
                      return 'Please enter a valid amount.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: salaryDateController,
                  decoration: const InputDecoration(
                    labelText: 'Salary Date (optional)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a goal title.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount (\$)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a target amount.';
                    }
                    final v = double.tryParse(value.trim());
                    if (v == null || v <= 0) {
                      return 'Please enter a valid amount.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDeadline,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Target Completion Date (optional)',
                    ),
                    child: Text(
                      selectedDeadline != null
                          ? '${selectedDeadline!.month}/${selectedDeadline!.day}/${selectedDeadline!.year}'
                          : 'Tap to select a date',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: isLoading ? null : saveGoal,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

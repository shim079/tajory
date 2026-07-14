import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../widgets/advisor_card.dart';
import '../widgets/goal_type_grid.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _firestoreService = FirestoreService();

  String? _selectedType;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a goal type')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final target = double.tryParse(_amountController.text.trim()) ?? 0;
      final title = _nameController.text.trim();

      await _firestoreService.addGoal(
        uid: user.uid,
        title: title,
        target: target,
      );

      await _firestoreService.logActivity(
        uid: user.uid,
        action: 'create_goal',
        description: 'Created goal: "$title"',
        xpEarned: 10,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal created!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5EF),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFDF9),
          surfaceTintColor: const Color(0xFFFFFDF9),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'اضافة هدف',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const AdvisorCard(),
              const SizedBox(height: 24),
              _buildSectionLabel('اسم الهدف'),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _nameController,
                labelText: 'Goal name',
                hintText: 'e.g. Apartment Rent',
                prefixIcon: const Icon(Icons.flag_outlined),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionLabel('نوع الهدف'),
              const SizedBox(height: 10),
              GoalTypeGrid(
                selectedType: _selectedType,
                onSelected: (type) => setState(() => _selectedType = type),
              ),
              const SizedBox(height: 24),
              _buildSectionLabel('المبلغ المستهدف'),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _amountController,
                labelText: 'Target amount',
                hintText: '0',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money_rounded),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 14),
                  child: Text(
                    '\uFDFC',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                validator: (v) {
                  final p = double.tryParse(v?.trim() ?? '');
                  if (p == null || p <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'اضافة هدف',
                onPressed: _submit,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

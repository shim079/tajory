import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/financial_goal.dart';
import '../services/firestore_service.dart';
import '../widgets/amount_button.dart';
import '../widgets/goal_selector_card.dart';
import 'completion_screen.dart';

class AddSavingsScreen extends StatefulWidget {
  final String? preselectedGoalId;

  const AddSavingsScreen({super.key, this.preselectedGoalId});

  @override
  State<AddSavingsScreen> createState() => _AddSavingsScreenState();
}

class _AddSavingsScreenState extends State<AddSavingsScreen> {
  final _firestoreService = FirestoreService();
  final _amountController = TextEditingController();

  List<FinancialGoal> _goals = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedGoalId;
  double _selectedQuickAmount = 0;

  static const _quickAmounts = [10.0, 50.0, 100.0, 500.0];

  @override
  void initState() {
    super.initState();
    _selectedGoalId = widget.preselectedGoalId;
    _loadGoals();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final gs = await _firestoreService.getGoals(user.uid);
      final active = gs.where((g) => !g.isCompleted).toList();
      if (!mounted) return;
      setState(() {
        _goals = active;
        _isLoading = false;
        if (_selectedGoalId == null && active.isNotEmpty) {
          _selectedGoalId = active.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _selectQuickAmount(double amount) {
    setState(() {
      _selectedQuickAmount = amount;
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  Future<void> _submit() async {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    if (_selectedGoalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a goal')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final goal = _goals.firstWhere((g) => g.id == _selectedGoalId);
      final newSaved = goal.saved + amount;

      await _firestoreService.updateGoalSaved(
        uid: user.uid,
        goalId: _selectedGoalId!,
        saved: newSaved,
      );

      await _firestoreService.addSavingsRecord(
        uid: user.uid,
        amount: amount,
        notes: 'Added via savings screen',
        goalId: _selectedGoalId,
      );

      final state = await _firestoreService.getIslandState(user.uid);
      final evolved = state.evolve(25);
      await _firestoreService.saveIslandState(uid: user.uid, state: evolved);

      await _firestoreService.logActivity(
        uid: user.uid,
        action: 'add_savings',
        description: 'Saved \$${amount.toStringAsFixed(2)} toward "${goal.title}"',
        xpEarned: 25,
      );

      if (newSaved >= goal.target) {
        await _firestoreService.completeGoal(uid: user.uid, goalId: _selectedGoalId!);
        await _firestoreService.logActivity(
          uid: user.uid,
          action: 'complete_goal',
          description: 'Completed goal: "${goal.title}"',
          xpEarned: 100,
        );
        if (!mounted) return;
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CompletionScreen()),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('\$${amount.toStringAsFixed(0)} saved to "${goal.title}"')),
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
    final theme = Theme.of(context);
    final green = const Color(0xFF2E7D32);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDF9),
        appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFDF9),
        surfaceTintColor: const Color(0xFFFFFDF9),
        title: Text(
          'اضافة ادخار',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _buildAdvisorCard(theme),
                const SizedBox(height: 20),
                _buildAmountSection(theme, green),
                const SizedBox(height: 24),
                _buildGoalSelectionSection(theme, green),
                const SizedBox(height: 32),
                _buildSubmitButton(green),
              ],
            ),
          ),
    );
  }

  Widget _buildAdvisorCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/adv.png',
              width: 82,
              height: 82,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Color(0xFF2E7D32), size: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرشدي المالي',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'وفر 5% من راتبك أو أكثر خلال الشهر',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(ThemeData theme, Color green) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المبلغ',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final val = double.tryParse(v);
              setState(() => _selectedQuickAmount = val ?? 0);
            },
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixIcon: const Icon(Icons.attach_money_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: green, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: _quickAmounts.map((amount) {
              final isSelected = _selectedQuickAmount == amount;
              return Padding(
                padding: const EdgeInsets.only(right: 5),
                child: AmountButton(
                  amount: amount,
                  isSelected: isSelected,
                  onTap: () => _selectQuickAmount(amount),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSelectionSection(ThemeData theme, Color green) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر هدفك',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (_goals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'لا توجد أهداف محددة. حدد هدفًا أولًا.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _goals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final goal = _goals[index];
                return GoalSelectorCard(
                  goal: goal,
                  isSelected: _selectedGoalId == goal.id,
                  onTap: () => setState(() => _selectedGoalId = goal.id),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton(Color green) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: _isSaving ? null : _submit,
        style: FilledButton.styleFrom(
          backgroundColor: green,
          disabledBackgroundColor: green.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'اضافة ادخار',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

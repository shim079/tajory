import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/financial_goal.dart';
import '../services/firestore_service.dart';
import 'completion_screen.dart';

class MyGoalsScreen extends StatefulWidget {
  const MyGoalsScreen({super.key});

  @override
  State<MyGoalsScreen> createState() => _MyGoalsScreenState();
}

class _MyGoalsScreenState extends State<MyGoalsScreen> {
  final firestoreService = FirestoreService();
  List<FinancialGoal> goals = [];
  bool isLoading = true;
  final Map<String, TextEditingController> _amountControllers = {};
  final Map<String, bool> _savingInProgress = {};

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  @override
  void dispose() {
    for (final c in _amountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String goalId) {
    return _amountControllers.putIfAbsent(goalId, () => TextEditingController());
  }

  Future<void> loadGoals() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final gs = await firestoreService.getGoals(user.uid);
      if (!mounted) return;
      setState(() {
        goals = gs;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load goals: $e')),
      );
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _addSavingsInline(FinancialGoal goal) async {
    final controller = _controllerFor(goal.id!);
    final text = controller.text.trim();
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => _savingInProgress[goal.id!] = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final newSaved = goal.saved + amount;

      await firestoreService.updateGoalSaved(
        uid: user.uid,
        goalId: goal.id!,
        saved: newSaved,
      );

      await firestoreService.addSavingsRecord(
        uid: user.uid,
        amount: amount,
        notes: 'Added via inline savings',
        goalId: goal.id,
      );

      final state = await firestoreService.getIslandState(user.uid);
      final evolved = state.evolve(25);
      await firestoreService.saveIslandState(uid: user.uid, state: evolved);

      await firestoreService.logActivity(
        uid: user.uid,
        action: 'add_savings',
        description: 'Saved \$${amount.toStringAsFixed(2)} toward "${goal.title}"',
        xpEarned: 25,
      );

      if (newSaved >= goal.target) {
        await firestoreService.completeGoal(uid: user.uid, goalId: goal.id!);
        await firestoreService.logActivity(
          uid: user.uid,
          action: 'complete_goal',
          description: 'Completed goal: "${goal.title}"',
          xpEarned: 100,
        );
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CompletionScreen()),
        );
        return;
      }

      if (!mounted) return;
      controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('\$${amount.toStringAsFixed(2)} added to "${goal.title}"')),
      );
      loadGoals();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingInProgress[goal.id!] = false);
    }
  }

  Future<void> showAddGoalSheet() async {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    DateTime? deadline;
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24, 12, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(ctx)
                              .colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'New Goal',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Goal title',
                        hintText: 'e.g. Emergency Fund',
                        prefixIcon: const Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Target amount',
                        hintText: 'e.g. 5000',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) {
                        final parsed = double.tryParse(v?.trim() ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: deadline ?? DateTime.now().add(
                              const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365 * 10)),
                        );
                        if (date != null) {
                          setSheetState(() => deadline = date);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Deadline (optional)',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          deadline != null
                              ? '${deadline!.month}/${deadline!.day}/${deadline!.year}'
                              : 'Select a date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              Navigator.pop(ctx, {
                                'title': titleController.text.trim(),
                                'target': double.tryParse(
                                    targetController.text.trim())!,
                                'deadline': deadline,
                              });
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Create Goal'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await firestoreService.addGoal(
        uid: user.uid,
        title: result['title'] as String,
        target: result['target'] as double,
        deadline: result['deadline'] as DateTime?,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal created!')),
      );
      loadGoals();
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

    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
      ),
      body: RefreshIndicator(
        onRefresh: loadGoals,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (activeGoals.isEmpty && completedGoals.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.flag_outlined,
                          size: 64, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'No goals yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set your first financial goal to start tracking progress.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (activeGoals.isNotEmpty) ...[
              Text(
                'Active Goals',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...activeGoals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    goal.title,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  '\$${goal.saved.toStringAsFixed(0)} / \$${goal.target.toStringAsFixed(0)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (goal.deadline != null) ...[
                                  Icon(Icons.event,
                                      size: 14,
                                      color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Due: ${goal.deadline!.month}/${goal.deadline!.day}/${goal.deadline!.year}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: (goal.daysRemaining ?? 999) < 0
                                          ? Colors.red
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                if (goal.daysRemaining != null &&
                                    goal.deadline != null)
                                  Text(
                                    goal.daysRemaining! >= 0
                                        ? '${goal.daysRemaining}d left'
                                        : 'Overdue!',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: (goal.daysRemaining ?? 999) < 0
                                          ? Colors.red
                                          : Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            if (goal.estimatedCompletionDate != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Est. completion: ${goal.estimatedCompletionDate}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: goal.progressPercent,
                                      minHeight: 10,
                                      backgroundColor: theme.colorScheme
                                          .surfaceContainerHighest,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(goal.progressPercent * 100).toStringAsFixed(0)}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Milestones: ${goal.milestonesReached}/4',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controllerFor(goal.id!),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Amount',
                                      prefixText: '\$ ',
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _savingInProgress[goal.id!] == true
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : IconButton(
                                        onPressed: () =>
                                            _addSavingsInline(goal),
                                        icon: const Icon(
                                            Icons.add_circle),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
            if (completedGoals.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Completed Goals',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...completedGoals.map((goal) => Card(
                    color: Colors.green.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.check_circle,
                          color: Colors.green),
                      title: Text(goal.title),
                      subtitle:
                          Text('Saved \$${goal.target.toStringAsFixed(0)}'),
                    ),
                  )),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

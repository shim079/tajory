import 'package:flutter/material.dart';
import 'registration_data.dart';

class StepFinancialGoals extends StatefulWidget {
  final RegistrationData data;
  final VoidCallback onNext;

  const StepFinancialGoals({
    super.key,
    required this.data,
    required this.onNext,
  });

  @override
  State<StepFinancialGoals> createState() => _StepFinancialGoalsState();
}

class _StepFinancialGoalsState extends State<StepFinancialGoals> {
  final Set<String> _selectedGoals = {};

  static const _goals = [
    _GoalOption('الدراسة', 'assets/images/دراسة.png'),
    _GoalOption('السفر', 'assets/images/سفر.png'),
    _GoalOption('السيارة', 'assets/images/سيارة.png'),
    _GoalOption('الادخار', 'assets/images/ادخار.png'),
    _GoalOption('الجهاز', 'assets/images/لابتوب.png'),
    _GoalOption('البيت', 'assets/images/بيت.png'),
    _GoalOption('الزواج', 'assets/images/زواج.png'),
    _GoalOption('اخرى', 'assets/images/اخرى.png'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedGoals.addAll(widget.data.financialGoals);
  }

  void _submit() {
    widget.data.financialGoals = _selectedGoals.toList();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'اختر هدفك المالي',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'يمكنك اختيار أكثر من هدف واحد.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: _goals.map((goal) {
                    final isSelected = _selectedGoals.contains(goal.label);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedGoals.remove(goal.label);
                          } else {
                            _selectedGoals.add(goal.label);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.08),
                              blurRadius: isSelected ? 16 : 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    goal.iconAsset,
                                    width: 80,
                                    height: 80,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    goal.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF2E7D32)
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2E7D32),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    disabledBackgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _submit,
                child: const Text('تخطي'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
    }
  }

class _GoalOption {
  final String label;
  final String iconAsset;

  const _GoalOption(this.label, this.iconAsset);
}

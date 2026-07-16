import 'package:flutter/material.dart';
import 'registration_data.dart';

class StepCompanion extends StatefulWidget {
  final RegistrationData data;
  final VoidCallback onNext;

  const StepCompanion({
    super.key,
    required this.data,
    required this.onNext,
  });

  @override
  State<StepCompanion> createState() => _StepCompanionState();
}

class _StepCompanionState extends State<StepCompanion> {
  String? _selectedCompanion;

  static const _companions = [
    _CompanionOption(
        'Home 1', 'home 1.png', 'A cozy starter home for your journey.'),
    _CompanionOption(
        'Home 2', 'home 2.png', 'A modern home with smart features.'),
    _CompanionOption(
        'Home 3', 'home 3.png', 'A vibrant home full of character.'),
    _CompanionOption(
        'Home 4', 'home 4.png', 'An elegant home with unique style.'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCompanion = widget.data.selectedCompanion;
  }

  void _submit() {
    if (_selectedCompanion == null) return;
    widget.data.selectedCompanion = _selectedCompanion;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padH = MediaQuery.of(context).size.width * 0.062;
    final bottomSpacer = MediaQuery.of(context).size.height * 0.19;

    return Padding(
      padding: EdgeInsets.fromLTRB(padH, 3, padH, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 3),
          Text(
            'اختر رفيقك في الرحلة',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'يمكنك اختيار رفيق واحد فقط.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _companions.map((companion) {
              final isSelected = _selectedCompanion == companion.name;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCompanion = companion.name);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.08),
                        blurRadius: isSelected ? 16 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: Image.asset(
                          'assets/images/${companion.asset}',
                          width: constraints.maxWidth * 0.85,
                          height: constraints.maxHeight * 0.85,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: _selectedCompanion != null ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                disabledBackgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.8),
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
          SizedBox(height: bottomSpacer),
        ],
      ),
    );
  }
}

class _CompanionOption {
  final String name;
  final String asset;
  final String description;

  const _CompanionOption(this.name, this.asset, this.description);
}

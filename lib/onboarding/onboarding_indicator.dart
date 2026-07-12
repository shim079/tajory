import 'package:flutter/material.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const OnboardingIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  static const _activeColor = Color(0xFF2E7D32);
  static const _inactiveColor = Colors.white;
  static const _borderColor = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: 12,
          height: 500,
          decoration: BoxDecoration(
            color: isActive ? _activeColor : _inactiveColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: _borderColor,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

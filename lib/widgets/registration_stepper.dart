import 'package:flutter/material.dart';

class RegistrationStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const RegistrationStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  static const _green = Color(0xFF2E7D32);
  static const _inactiveColor = Color(0xFFBDBDBD);
  static const _inactiveBg = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? _green : _inactiveColor,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final state = _stepState(stepIndex);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCircle(stepIndex, state),
            const SizedBox(height: 6),
            Text(
              stepLabels[stepIndex],
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }),
    );
  }

  _StepState _stepState(int index) {
    if (index < currentStep) return _StepState.completed;
    if (index == currentStep) return _StepState.current;
    return _StepState.upcoming;
  }

  Widget _buildCircle(int index, _StepState state) {
    final size = state == _StepState.current ? 28.0 : 24.0;

    switch (state) {
      case _StepState.completed:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: _green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        );
      case _StepState.current:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: _green,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        );
      case _StepState.upcoming:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _inactiveBg,
            shape: BoxShape.circle,
            border: Border.all(color: _inactiveColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _inactiveColor,
              ),
            ),
          ),
        );
    }
  }
}

enum _StepState { completed, current, upcoming }

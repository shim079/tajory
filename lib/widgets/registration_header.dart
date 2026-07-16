import 'package:flutter/material.dart';
import 'registration_stepper.dart';

class RegistrationHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  static const stepLabels = [
    'البيانات الشخصية',
    'اختيار الهدف',
    'اختيار الرفيق',
    'بيانات الحساب',
  ];

  const RegistrationHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFDF9),
      padding: EdgeInsets.only(top: statusBarHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: onBack != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8, top: 4),
                    child: IconButton(
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Colors.black87,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(40, 40),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: RegistrationStepper(
              currentStep: currentStep,
              totalSteps: totalSteps,
              stepLabels: stepLabels,
            ),
          ),
        ],
      ),
    );
  }
}

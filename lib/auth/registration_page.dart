import 'package:flutter/material.dart';
import '../widgets/registration_header.dart';
import 'registration_data.dart';
import 'step_personal_info.dart';
import 'step_financial_goals.dart';
import 'step_companion.dart';
import 'step_account.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _pageController = PageController();
  final _data = RegistrationData();
  int _currentStep = 0;

  static const _totalSteps = 4;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sandHeight = MediaQuery.of(context).size.height * 0.14;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/fullbg.png',
              fit: BoxFit.cover,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: sandHeight,
              child: Image.asset(
                'assets/images/sand.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Column(
              children: [
                RegistrationHeader(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                  onBack: _previousStep,
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StepPersonalInfo(data: _data, onNext: _nextStep),
                      StepFinancialGoals(data: _data, onNext: _nextStep),
                      StepCompanion(data: _data, onNext: _nextStep),
                      StepAccount(data: _data),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

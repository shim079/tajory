import 'dart:ui';

enum OnboardingIllustrationType {
  logo,
  desertOnly,
  floatingGoals,
  advisor,
}

class OnboardingData {
  final String title;
  final String description;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final bool showSkip;
  final OnboardingIllustrationType illustrationType;
  final Color? backgroundColor;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.primaryButtonText,
    this.secondaryButtonText,
    this.showSkip = true,
    required this.illustrationType,
    this.backgroundColor,
  });
}

const List<OnboardingData> onboardingPages = [
  OnboardingData(
    title: '',
    description:
        'Your smart companion for building better financial habits and achieving your financial goals.',
    primaryButtonText: 'Next',
    illustrationType: OnboardingIllustrationType.logo,
  ),
  OnboardingData(
    title: 'Start Your Financial Journey',
    description:
        'Every saving step brings you closer to the future you dream of.',
    primaryButtonText: 'Next',
    illustrationType: OnboardingIllustrationType.desertOnly,
  ),
  OnboardingData(
    title: 'Save for Your Goals',
    description:
        'Create goals, track your savings, and celebrate every milestone.',
    primaryButtonText: 'Next',
    illustrationType: OnboardingIllustrationType.floatingGoals,
    backgroundColor: Color(0xFFF8F5EF),
  ),
  OnboardingData(
    title: 'Your Financial Companion',
    description:
        'Track your expenses, receive smart insights, and achieve your goals with confidence.',
    primaryButtonText: 'Get Started',
    secondaryButtonText: 'Already have an account? Log In',
    showSkip: false,
    illustrationType: OnboardingIllustrationType.advisor,
    backgroundColor: Color(0xFFF8F5EF),
  ),
];

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
    backgroundColor: Color(0xFFF8F5EF),
  ),
  OnboardingData(
    title: 'ابدأ رحلتك نحو مستقبل مالي أفضل',
    description:
        'حول كل مبلغ تدخره الى خطوة جديدة, وشاهد واحتك تنمو مع كل انجاز.',
    primaryButtonText: 'Next',
    illustrationType: OnboardingIllustrationType.desertOnly,
    backgroundColor: null,
  ),
  OnboardingData(
    title: 'ابدا ادخارك الأن',
    description:
        'حدد هدفك المالي وسنساعدك على الوصول اليه خطوة بخطوة.',
    primaryButtonText: 'Next',
    illustrationType: OnboardingIllustrationType.floatingGoals,
    backgroundColor: Color(0xFFF8F5EF),
  ),
  OnboardingData(
    title: 'مرشدك المالي معك في كل خطوة',
    description:
        'احصل على نصائح دكية و تتبع تقدمك واكتشف عاداتك المالية.',
    primaryButtonText: 'Get Started',
    secondaryButtonText: 'هل لديك حساب بالفعل؟ سجّل الدخول',
    showSkip: false,
    illustrationType: OnboardingIllustrationType.advisor,
    backgroundColor: Color(0xFFF8F5EF),
  ),
];

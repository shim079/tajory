import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/auth_wrapper.dart';
import 'onboarding_data.dart';
import 'onboarding_page.dart';
import 'onboarding_indicator.dart';
import 'onboarding_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;

  static final _totalPages = onboardingPages.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 10), () {
      if (_currentPage == 0 && mounted) {
        _nextPage();
      }
    });
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final data = onboardingPages[_currentPage];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _totalPages,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return OnboardingPage(data: onboardingPages[index]);
              },
            ),
            if (_currentPage > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: size.height * 0.22,
                child: Center(
                  child: OnboardingIndicator(
                    currentPage: _currentPage,
                    pageCount: _totalPages,
                  ),
                ),
              ),
            if (_currentPage > 0)
              Positioned(
                left: 28,
                right: 28,
                bottom: size.height * 0.15,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OnboardingPrimaryButton(
                      text: data.primaryButtonText,
                      onPressed: _nextPage,
                    ),
                    if (data.showSkip) ...[
                      const SizedBox(height: 8),
                      OnboardingSecondaryButton(
                        text: 'Skip',
                        onPressed: _completeOnboarding,
                      ),
                    ] else if (data.secondaryButtonText != null) ...[
                      const SizedBox(height: 8),
                      OnboardingSecondaryButton(
                        text: data.secondaryButtonText!,
                        onPressed: _completeOnboarding,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

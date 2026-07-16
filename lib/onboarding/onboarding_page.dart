import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'onboarding_data.dart';
import 'onboarding_background.dart';

class OnboardingPage extends StatefulWidget {
  final OnboardingData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late final List<AnimationController> _floatingControllers;
  late final List<Animation<double>> _floatAnimations;

  @override
  void initState() {
    super.initState();
    _floatingControllers = [];
    _floatAnimations = [];

    if (widget.data.illustrationType ==
        OnboardingIllustrationType.floatingGoals) {
      for (int i = 0; i < 3; i++) {
        final controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 2000 + i * 400),
        );
        _floatingControllers.add(controller);
        _floatAnimations.add(
          Tween<double>(begin: 0, end: 12 + i * 3.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        );
      }
      for (final c in _floatingControllers) {
        c.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _floatingControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final splitTop = size.height * 0.49;
    final sandHeight = size.height * 0.14;
    final logoSize = size.width * 0.56;
    final logoHeight = logoSize * 1.25;

    if (widget.data.illustrationType == OnboardingIllustrationType.logo) {
      return Container(
        color: widget.data.backgroundColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: logoSize,
                    height: logoHeight,
                    child: Image.asset(
                      'assets/images/tajory.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تجوري',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
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
          ],
        ),
      );
    }

    return Stack(
      children: [
        OnboardingBackground(
          backgroundColor: widget.data.backgroundColor,
          child: _buildIllustration(size),
        ),
        Positioned(
          top: splitTop,
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildContentArea(context),
        ),
      ],
    );
  }

  Widget _buildIllustration(Size size) {
    switch (widget.data.illustrationType) {
      case OnboardingIllustrationType.logo:
        return _buildLogoIllustration(size);
      case OnboardingIllustrationType.desertOnly:
        return const SizedBox.expand();
      case OnboardingIllustrationType.floatingGoals:
        return _buildFloatingGoals(size);
      case OnboardingIllustrationType.advisor:
        return _buildAdvisorIllustration(size);
    }
  }

  Widget _buildLogoIllustration(Size size) {
    return Center(
      child: SvgPicture.asset(
        'assets/images/tajory.svg',
        height: size.height * 0.12,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAdvisorIllustration(Size size) {
    final imgSize = size.width * 0.92;
    final topOffset = size.height * 0.09;
    return Stack(
      children: [
        Positioned(
          top: topOffset,
          left: size.width * 0.04,
          width: imgSize,
          height: imgSize,
          child: Image.asset(
            'assets/images/advisor.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingGoals(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge(_floatingControllers),
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: size.height * 0.07 + _floatAnimations[2].value,
              right: size.width * 0.2,
              child: Container(
                width: size.width * 0.32,
                height: size.width * 0.32,
                decoration: const BoxDecoration(
                  color: Color(0x805C8A5A),
                  shape: BoxShape.circle,
                ),
                child: _buildGoalImage(
                  'assets/images/سفر.png',
                  size.width * 0.28,
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.20 + _floatAnimations[1].value,
              left: size.width * 0.08,
              child: Container(
                width: size.width * 0.33,
                height: size.width * 0.33,
                decoration: const BoxDecoration(
                  color: Color(0x80D8C3A5),
                  shape: BoxShape.circle,
                ),
                child: _buildGoalImage(
                  'assets/images/سيارة.png',
                  size.width * 0.32,
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.03 + _floatAnimations[0].value,
              left: size.width * 0.50,
              child: Container(
                width: size.width * 0.34,
                height: size.width * 0.34,
                decoration: const BoxDecoration(
                  color: Color(0x80D4A64A),
                  shape: BoxShape.circle,
                ),
                child: _buildGoalImage(
                  'assets/images/بيت.png',
                  size.width * 0.34,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalImage(String assetPath, double height) {
    return Image.asset(
      assetPath,
      height: height,
      fit: BoxFit.contain,
    );
  }

  Widget _buildContentArea(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.06),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: size.width * 0.072),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.03,
          vertical: size.height * 0.038,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

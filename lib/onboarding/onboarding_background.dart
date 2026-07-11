import 'package:flutter/material.dart';

class OnboardingBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const OnboardingBackground({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final useDesert = backgroundColor == null;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (useDesert)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 410,
            child: Image.asset(
              'assets/images/desert.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        if (!useDesert)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 410,
            child: Container(color: backgroundColor),
          ),
        Positioned(
          top: 410,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 24,
                  spreadRadius: 4,
                  offset: Offset(0, -4),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 410,
          child: child,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 120,
          child: Image.asset(
            'assets/images/sand.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }
}

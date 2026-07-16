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
    final size = MediaQuery.of(context).size;
    final splitTop = size.height * 0.49;
    final sandHeight = size.height * 0.14;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (useDesert)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/desert.png',
              fit: BoxFit.contain,
              alignment: Alignment(-0.5, -1),
            ),
          ),
        if (!useDesert)
          Container(
            color: backgroundColor,
          ),
        Positioned(
          top: splitTop,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: useDesert
                  ? []
                  : const [
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
          height: splitTop,
          child: child,
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
    );
  }
}

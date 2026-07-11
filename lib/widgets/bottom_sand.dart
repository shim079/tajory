import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomSandWidget extends StatelessWidget {
  const BottomSandWidget({super.key});

  static double heightOf(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.15;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: heightOf(context),
      child: SvgPicture.asset(
        'assets/images/sand.svg',
        fit: BoxFit.fitWidth,
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}

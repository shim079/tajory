import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPad = MediaQuery.of(context).size.height * 0.064;
    final padH = MediaQuery.of(context).size.width * 0.051;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        color: const Color(0xFFF8F5EF),
        padding: EdgeInsets.only(left: padH, right: padH, top: topPad, bottom: 12),
        child: Row(
          children: [
            if (trailing != null) ...[
              trailing!,
              const Spacer(flex: 2),
            ],
            Expanded(
              flex: 5,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            if (trailing != null) const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

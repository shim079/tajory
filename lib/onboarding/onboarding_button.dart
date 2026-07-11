import 'package:flutter/material.dart';

class OnboardingPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OnboardingPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class OnboardingSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OnboardingSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/pet_model.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final bool isSelected;
  final VoidCallback onTap;

  const PetCard({
    super.key,
    required this.pet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2.5,
                )
              : BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
        ),
        elevation: isSelected ? 4 : 1,
        shadowColor: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.3)
            : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : null,
            ),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      pet.emoji,
                      style: const TextStyle(fontSize: 56),
                    ),
                    if (isSelected)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  pet.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pet.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

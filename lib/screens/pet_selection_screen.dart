import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pet_model.dart';
import '../services/pet_service.dart';
import '../widgets/pet_card.dart';
import '../widgets/bottom_sand.dart';
import 'home_screen.dart';

class PetSelectionScreen extends StatefulWidget {
  const PetSelectionScreen({super.key});

  @override
  State<PetSelectionScreen> createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends State<PetSelectionScreen> {
  final petService = PetService();
  Pet? selectedPet;
  bool isLoading = false;

  Future<void> savePet() async {
    if (selectedPet == null) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await petService.saveSelectedPet(
        uid: user.uid,
        pet: selectedPet!,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save pet: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = BottomSandWidget.heightOf(context) + 24;
    final padH = MediaQuery.of(context).size.width * 0.062;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Companion'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padH, 24, padH, bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.pets_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select a companion pet',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This pet will be your financial journey companion.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: PetService.availablePets.map(
                      (pet) => PetCard(
                        pet: pet,
                        isSelected: selectedPet?.id == pet.id,
                        onTap: () => setState(() => selectedPet = pet),
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: selectedPet != null && !isLoading ? savePet : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Complete Setup',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: BottomSandWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

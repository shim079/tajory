import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';

class PetService {
  static const List<Pet> availablePets = [
    Pet(
      id: 'tiger',
      name: 'Tiger',
      emoji: '\u{1F405}',
      description: 'Bold, determined, and always moving toward big goals.',
    ),
    Pet(
      id: 'deer',
      name: 'Deer',
      emoji: '\u{1F98C}',
      description: 'Calm, patient, and grows steadily over time.',
    ),
    Pet(
      id: 'goat',
      name: 'Goat',
      emoji: '\u{1F410}',
      description: 'Persistent, adaptable, and never gives up.',
    ),
    Pet(
      id: 'camel',
      name: 'Camel',
      emoji: '\u{1F42A}',
      description: 'Wise, resilient, and excellent at saving resources.',
    ),
  ];

  static const Map<String, String> _companionAssets = {
    'Home 1': 'assets/images/home 1.png',
    'Home 2': 'assets/images/home 2.png',
    'Home 3': 'assets/images/home 3.png',
    'Home 4': 'assets/images/home 4.png',
  };

  static String? getCompanionAssetPath(String? selectedPet) {
    if (selectedPet == null || selectedPet.isEmpty) return null;
    return _companionAssets[selectedPet];
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveSelectedPet({
    required String uid,
    required Pet pet,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'selectedPet': pet.toMap(),
      'setupComplete': true,
    });
  }

  Future<Pet?> getSelectedPet(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) return null;

      final petData = data['selectedPet'];
      if (petData is Map<String, dynamic>) {
        return Pet.fromMap(petData);
      }

      if (petData is String) {
        final matches = availablePets.where((p) => p.id == petData);
        if (matches.isNotEmpty) return matches.first;

        final assetPath = getCompanionAssetPath(petData);
        if (assetPath != null) {
          return Pet(
            id: petData.toLowerCase().replaceAll(' ', '_'),
            name: petData,
            emoji: '\u{1F3E0}',
            description: 'Your chosen companion.',
          );
        }
        return null;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}

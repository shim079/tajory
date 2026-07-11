import 'dart:io';

class RegistrationData {
  String fullName = '';
  double monthlyIncome = 0;
  String salaryDate = '';
  File? bankStatement;
  List<String> financialGoals = [];
  String? selectedCompanion;
  String email = '';
  String password = '';

  Map<String, dynamic> toMap() => {
        'name': fullName,
        'email': email,
        'income': monthlyIncome,
        'salaryDate': salaryDate,
        'financialGoals': financialGoals,
        'selectedCompanion': selectedCompanion,
        'createdAt': DateTime.now().toIso8601String(),
        'setupComplete': false,
      };
}

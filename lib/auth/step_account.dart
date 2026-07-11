import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'registration_data.dart';
import 'auth_service.dart';
import '../services/firestore_service.dart';
import '../screens/home_screen.dart';

class StepAccount extends StatefulWidget {
  final RegistrationData data;

  const StepAccount({super.key, required this.data});

  @override
  State<StepAccount> createState() => _StepAccountState();
}

class _StepAccountState extends State<StepAccount> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<String?> _uploadBankStatement(String uid) async {
    final file = widget.data.bankStatement;
    if (file == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('users/$uid/bank_statement/${file.path.split('/').last}');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Bank statement upload error: $e');
      return null;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed.')),
        );
        return;
      }

      final bankStatementUrl = await _uploadBankStatement(user.uid);

      await _firestoreService.createUser(
        uid: user.uid,
        name: widget.data.fullName,
        email: _emailController.text.trim(),
        income: widget.data.monthlyIncome,
        salaryDate: widget.data.salaryDate,
        financialGoals: widget.data.financialGoals,
        selectedCompanion: widget.data.selectedCompanion,
        bankStatementUrl: bankStatementUrl,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'Create your account',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your email and password to finish setup.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 1),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email.';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 1),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a password.';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _register(),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 1),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please confirm your password.';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _register,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Account'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

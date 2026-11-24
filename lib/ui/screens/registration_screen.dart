import 'package:flutter/material.dart';
import 'package:flutter_app/domain/repositories/i_user_repository.dart';
import 'package:flutter_app/domain/validators/auth_validator.dart';
import 'package:flutter_app/ui/widgets/auth_layout.dart';
import 'package:flutter_app/ui/widgets/form_error_text.dart';
import 'package:flutter_app/ui/widgets/input_text_field.dart';
import 'package:flutter_app/ui/widgets/loading_elevated_button.dart';

class RegistrationScreen extends StatefulWidget {
  final IUserRepository authRepository;

  const RegistrationScreen({required this.authRepository, super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await widget.authRepository.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = 'User with this email already exists.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormErrorText(message: _errorMessage),
            CustomTextField(
              label: 'Full Name',
              controller: _nameController,
              validator: AuthValidator.validateName,
            ),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidator.validateEmail,
            ),
            CustomTextField(
              label: 'Password',
              isPassword: true,
              controller: _passwordController,
              validator: AuthValidator.validateRegistrationPassword,
            ),
            CustomTextField(
              label: 'Confirm Password',
              isPassword: true,
              controller: _confirmPasswordController,
              validator: (value) => AuthValidator.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
            ),
            const SizedBox(height: 8),
            LoadingElevatedButton(
              label: 'Enter',
              isLoading: _isLoading,
              onPressed: _handleRegister,
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.pushNamed(context, '/login');
                    },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

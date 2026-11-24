import 'package:flutter/material.dart';

class FormErrorText extends StatelessWidget {
  final String? message;

  const FormErrorText({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final errorMessage = message;
    if (errorMessage == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.redAccent),
        textAlign: TextAlign.center,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/widgets/centered_content.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.popUntil(context, ModalRoute.withName('/'));
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CenteredContent(child: SingleChildScrollView(child: child)),
          ),
        ),
      ),
    );
  }
}

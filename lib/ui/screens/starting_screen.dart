import 'package:flutter/material.dart';
import 'package:flutter_app/ui/widgets/centered_content.dart';

class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CenteredContent(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.device_unknown, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                const Text(
                  'Smart Sync Hub',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Login', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Register', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

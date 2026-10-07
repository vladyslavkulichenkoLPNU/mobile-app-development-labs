import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/settings_tile.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hub Settings & Profile')),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width > 600
              ? 600
              : MediaQuery.of(context).size.width,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'John Doe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(child: Text('john.doe@smarthome.com')),
              const SizedBox(height: 32),
              const Divider(),
              SettingsTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                trailing: Switch(value: true, onChanged: (val) {}),
              ),
              SettingsTile(
                icon: Icons.wifi,
                title: 'Connected Network',
                subtitle: 'Home_5GHz',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

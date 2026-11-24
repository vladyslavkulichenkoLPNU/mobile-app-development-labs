import 'package:flutter_app/domain/models/user.dart';
import 'package:flutter_app/domain/repositories/i_user_repository.dart';
import 'package:flutter_app/ui/widgets/centered_content.dart';
import 'package:flutter_app/ui/widgets/confirm_dialog.dart';
import 'package:material_ui/material_ui.dart';

class UserProfileScreen extends StatefulWidget {
  final IUserRepository authRepository;

  const UserProfileScreen({required this.authRepository, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await widget.authRepository.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _confirmLogout() async {
    if (_isLoggingOut) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Log Out',
      content: 'Are you sure you want to log out?',
      confirmLabel: 'Log Out',
    );

    if (confirmed && mounted) {
      await _handleLogout();
    }
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);

    try {
      await widget.authRepository.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentUser = _currentUser;
    if (currentUser == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No active user session found.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: const Text('Return to Start'),
              ),
            ],
          ),
        ),
      );
    }

    return CenteredContent(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Full Name'),
            subtitle: Text(currentUser.name),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email Address'),
            subtitle: Text(currentUser.email),
          ),
          const Divider(),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _isLoggingOut ? null : _confirmLogout,
            icon: _isLoggingOut
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.redAccent,
                    ),
                  )
                : const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text(
              'Log Out',
              style: TextStyle(color: Colors.redAccent),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hub Settings & Profile')),
      body: _buildBody(context),
    );
  }
}

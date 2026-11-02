import 'package:flutter/material.dart';
import 'package:flutter_app/models/routine.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/registration_screen.dart';
import 'package:flutter_app/screens/starting_screen.dart';
import 'package:flutter_app/screens/user_profile_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RoutineAdapter());
  await Hive.openBox<Routine>('routinesBox');
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('usersBox');
  runApp(const SmartSyncApp());
}

class SmartSyncApp extends StatelessWidget {
  const SmartSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Sync Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/dashboard': (context) => const HomeScreen(),
        '/profile': (context) => const UserProfileScreen(),
      },
    );
  }
}

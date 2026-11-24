import 'package:flutter/material.dart';
import 'package:flutter_app/data/adapters/routine_adapter.dart';
import 'package:flutter_app/data/adapters/user_adapter.dart';
import 'package:flutter_app/data/repositories/hive_routine_repository.dart';
import 'package:flutter_app/data/repositories/hive_user_repository.dart';
import 'package:flutter_app/domain/constants/default_routines.dart';
import 'package:flutter_app/domain/models/routine.dart';
import 'package:flutter_app/domain/models/user.dart';
import 'package:flutter_app/domain/repositories/i_routine_repository.dart';
import 'package:flutter_app/domain/repositories/i_user_repository.dart';
import 'package:flutter_app/ui/screens/home_screen.dart';
import 'package:flutter_app/ui/screens/login_screen.dart';
import 'package:flutter_app/ui/screens/registration_screen.dart';
import 'package:flutter_app/ui/screens/starting_screen.dart';
import 'package:flutter_app/ui/screens/user_profile_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RoutineAdapter());
  final routinesBox = await Hive.openBox<Routine>('routinesBox');
  Hive.registerAdapter(UserAdapter());
  final usersBox = await Hive.openBox<User>('usersBox');
  final settingsBox = await Hive.openBox<bool>('settingsBox');

  final IUserRepository userRepository = HiveUserRepository(usersBox);
  final IRoutineRepository routineRepository = HiveRoutineRepository(
    routinesBox,
  );

  if (settingsBox.get('routinesSeeded') != true) {
    if (routinesBox.isEmpty) {
      for (final routine in defaultRoutines) {
        await routineRepository.addRoutine(routine);
      }
    }
    await settingsBox.put('routinesSeeded', true);
  }

  final currentUser = await userRepository.getCurrentUser();

  runApp(
    SmartSyncApp(
      userRepository: userRepository,
      routineRepository: routineRepository,
      initialRoute: currentUser != null ? '/dashboard' : '/',
    ),
  );
}

class SmartSyncApp extends StatelessWidget {
  final IUserRepository userRepository;
  final IRoutineRepository routineRepository;
  final String initialRoute;

  const SmartSyncApp({
    required this.userRepository,
    required this.routineRepository,
    required this.initialRoute,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Sync Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const StartingScreen(),
        '/login': (context) => LoginScreen(authRepository: userRepository),
        '/register': (context) =>
            RegistrationScreen(authRepository: userRepository),
        '/dashboard': (context) =>
            HomeScreen(routineRepository: routineRepository),
        '/profile': (context) =>
            UserProfileScreen(authRepository: userRepository),
      },
    );
  }
}

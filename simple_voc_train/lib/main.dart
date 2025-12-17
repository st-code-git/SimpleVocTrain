// lib/main.dart


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/vocabulary_trainer_screen.dart';
import 'screens/login_page.dart';
import 'screens/password_reset_screen.dart';
import 'screens/settings_page.dart';
import 'services/supabase_service.dart';
import 'services/language_service.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.instance.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageService()..loadLanguages(), 
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      print("Auth State changed: $event");

      if (event == AuthChangeEvent.passwordRecovery) {

        navigatorKey.currentState?.pushNamed('/update-password-page');
      }

      if(event == AuthChangeEvent.signedIn) {

        final fullUrl = Uri.base.toString();

        if(fullUrl.contains('type=invite')) {

          print("Invite Link erkannt");
          navigatorKey.currentState?.pushNamed('/update-password-page');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vokabel Trainer',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 234, 232, 243),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 234, 232, 243),
          foregroundColor: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      navigatorKey: navigatorKey, 
      
      // Routes
      routes: {
        '/': (context) => const AuthGate(), 
        '/home': (context) => const VocabularyTrainerScreen(),
        '/login': (context) => const LoginPage(),
        '/update-password-page': (context) => const PasswordResetScreen(),
        '/settings-page': (context) => const SettingsPage(),
      },
    );
  }
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        
        // Loading circle
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return const VocabularyTrainerScreen(); //Logged in
        } else {
          return const LoginPage(); //Logged out
        }
      },
    );
  }
}

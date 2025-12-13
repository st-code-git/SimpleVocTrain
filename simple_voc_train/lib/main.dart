// lib/main.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/vocabulary_trainer_screen.dart';
import 'screens/login_page.dart';
import 'screens/password_reset_screen.dart';
import 'screens/settings_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const String supabaseUrl = '';
const String supabaseAnonKey = '';
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
  await dotenv.load(fileName: "assets/env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,

    authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.implicit,
    ),
  );
  } catch (e) {
    print("Fehler beim Start: $e"); 
  }

  runApp(const MyApp());
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
    
    // 2. Der Listener für den Invite-Link
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      print("Auth State changed: $event");

      if (event == AuthChangeEvent.passwordRecovery) {
        // Schiebt die Passwort-Seite über alles andere drüber
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
      navigatorKey: navigatorKey, // <--- Nicht vergessen!
      
      // 3. Hier definierst du alle Routen
      routes: {
        '/': (context) => const AuthGate(), // Startpunkt ist die Weiche
        '/home': (context) => const VocabularyTrainerScreen(),
        '/login': (context) => const LoginPage(),
        '/update-password-page': (context) => const PasswordResetScreen(),
        '/settings-page': (context) => SettingsPage(),
      },
    );
  }
}

// 4. Das AuthGate Widget (Die Weiche)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Wir fragen direkt beim Stream ab, damit es sich live aktualisiert
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        
        // Noch am Laden? Zeige Ladekreis
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Haben wir eine Session?
        final session = snapshot.data?.session;

        if (session != null) {
          return const VocabularyTrainerScreen(); // Eingeloggt -> Home
        } else {
          return const LoginPage(); // Ausgeloggt -> Login
        }
      },
    );
  }
}

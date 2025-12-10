// lib/main.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/vocabulary_trainer_screen.dart';
import 'screens/login_page.dart';


// Ersetzen Sie DIESE PLATZHALTER durch Ihre echten Supabase-Werte
const String supabaseUrl = '';
const String supabaseAnonKey = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
  // Lade die .env-Datei
  await dotenv.load(fileName: "assets/env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  } catch (e) {
    print("Fehler beim Start: $e"); // Siehst du in der F12 Konsole
  }

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vokabeltrainer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // 1. Wir lauschen auf Änderungen am Login-Status
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        
        // 2. Während Supabase noch kurz lädt, zeigen wir einen Ladekreis
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 3. Prüfen, ob eine Session existiert
        final session = snapshot.data?.session;

        if (session != null) {
          // User ist eingeloggt -> Zum Home Screen
          return const VocabularyTrainerScreen();
        } else {
          // Kein User -> Zum Login Screen
          return const LoginPage();
        }
      },
    );
  }
}

Future<void> signIn(String email, String password) async {
  try {
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    final User? user = res.user;
    print("Eingeloggt als: ${user?.email}");
    
    // Weiterleiten zum Home Screen...
  } catch (e) {
    print("Fehler beim Login: $e");
  }
}
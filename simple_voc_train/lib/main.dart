// lib/main.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/vocabulary_trainer_screen.dart';


// Ersetzen Sie DIESE PLATZHALTER durch Ihre echten Supabase-Werte
const String supabaseUrl = '';
const String supabaseAnonKey = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lade die .env-Datei
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
      home: const VocabularyTrainerScreen(),
    );
  }
}
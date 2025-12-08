// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/vocabulary_trainer_screen.dart';

// Ersetzen Sie DIESE PLATZHALTER durch Ihre echten Supabase-Werte
const String supabaseUrl = '';
const String supabaseAnonKey = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
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
import 'package:flutter/material.dart';
import '../main.dart'; // Zugriff auf den globalen 'supabase' Client
import 'trainer_query_tab.dart';
import 'trainer_create_tab.dart';
import '../services/supabase_service.dart';
import '../services/language_service.dart';
import 'package:provider/provider.dart';

const String appVersion = String.fromEnvironment(
  'APP_VERSION', 
  defaultValue: 'DEV-Mode'
);

class VocabularyTrainerScreen extends StatefulWidget {
  const VocabularyTrainerScreen({super.key});
  
  @override
  State<VocabularyTrainerScreen> createState() => _VocabularyTrainerScreenState();
}

class _VocabularyTrainerScreenState extends State<VocabularyTrainerScreen> {
  // Singleton 
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();

    _supabaseService = SupabaseService.instance;
  }

  @override
  Widget build(BuildContext context) {

    final languageService = context.read<LanguageService>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('easyvoc - einfach Vokabeln lernen'),
          
          actions: [     
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 32.0),
                child: Text(
                  'v$appVersion', 
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),
              ),
            ),    
            IconButton(
              icon: const Icon(Icons.menu), 
              tooltip: 'Konfiguration', 
              onPressed: () {
                setState(() {
                  navigatorKey.currentState?.pushNamed('/settings-page');
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Ausloggen',
              onPressed: () async {
                //showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
                try 
                {
                  await _supabaseService.signOut();
                } catch (e) {
                  Navigator.pop(context); // Lade-Indikator weg
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logout fehlgeschlagen: $e")));
                }
              },
            ),
        ],

          bottom: const TabBar(
            tabs: [
              Tab(text: 'Abfrage', icon: Icon(Icons.quiz)),
              Tab(text: 'Verwaltung', icon: Icon(Icons.edit_note)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TrainerQueryTab(
              supabaseService: _supabaseService,
              currentLanguage: languageService.lang1,
            ),

            TrainerCreateTab(
              supabaseService: _supabaseService,
            ),
          ],
        ),
      ),
    );
  }
}
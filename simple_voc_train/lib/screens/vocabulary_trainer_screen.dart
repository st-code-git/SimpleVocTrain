import 'package:flutter/material.dart';
import '../main.dart'; // Zugriff auf den globalen 'supabase' Client
import '../services/supabase_service.dart';
import 'trainer_query_tab.dart';
import 'trainer_create_tab.dart';
import '../screens/settings_page.dart';

class VocabularyTrainerScreen extends StatefulWidget {
  const VocabularyTrainerScreen({super.key});

  @override
  State<VocabularyTrainerScreen> createState() => _VocabularyTrainerScreenState();
}

class _VocabularyTrainerScreenState extends State<VocabularyTrainerScreen> {
  // Singleton verwenden, keine neue Instanz nötig
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    // Lazy-initialisierte Singleton-Instanz holen
    _supabaseService = SupabaseService.instance;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('easyvoc - einfach Vokabeln lernen'),
          
          actions: [         
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
                await _supabaseService.signOut();
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
            // Tab 1: Abfrage
            TrainerQueryTab(
              supabaseService: _supabaseService,
              // Wir geben eine Standardsprache mit, können sie aber im Tab ändern
              currentLanguage: AppLanguages.language_1, 
            ),
            
            // Tab 2: Anlegen / Bearbeiten
            TrainerCreateTab(
              supabaseService: _supabaseService,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../main.dart'; // Zugriff auf den globalen 'supabase' Client
import '../services/supabase_service.dart';
import 'trainer_query_tab.dart';
import 'trainer_create_tab.dart';

class VocabularyTrainerScreen extends StatefulWidget {
  const VocabularyTrainerScreen({super.key});

  @override
  State<VocabularyTrainerScreen> createState() => _VocabularyTrainerScreenState();
}

class _VocabularyTrainerScreenState extends State<VocabularyTrainerScreen> {
  // Wir erstellen den Service hier einmalig
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(supabase);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vokabeltrainer Master'),
          // Der globale Sprachwähler (Dropdown) wurde entfernt, 
          // da er für den "Anlegen"-Tab keinen Sinn mehr ergibt.
          
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
              currentLanguage: AppLanguage1.german, 
            ),
            
            // Tab 2: Anlegen / Bearbeiten
            // HIER WAR DER FEHLER: Wir übergeben keine 'currentLanguage' mehr!
            TrainerCreateTab(
              supabaseService: _supabaseService,
            ),
          ],
        ),
      ),
    );
  }
}
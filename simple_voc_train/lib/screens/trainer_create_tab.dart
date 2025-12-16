import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../services/language_service.dart'; 
import '../models/vocabulary.dart';
import '../models/app_language.dart';
import 'package:postgrest/postgrest.dart';
import 'settings_page.dart';


enum CreationMode { createNew, extendExisting }

class TrainerCreateTab extends StatefulWidget {
  final SupabaseService supabaseService;
  const TrainerCreateTab({super.key, required this.supabaseService});

  @override
  State<TrainerCreateTab> createState() => _TrainerCreateTabState();
}

class _TrainerCreateTabState extends State<TrainerCreateTab> {
  CreationMode _mode = CreationMode.createNew;
  
  // Map von Sprache -> Liste von 5 Controllern
  final Map<AppLanguage, List<TextEditingController>> _controllers = {};
  
  //Statt nur IDs speichern wir die ganzen Objekte für das Dropdown
  List<Vocabulary> _availableSets = [];
  int? _selectedId;
  
  String? _message;
  bool _isLoading = false;

  bool _isInit = true; // Hilfsvariable, damit wir Controller nicht doppelt erstellen

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      // Hier ist der Context sicher verfügbar!
      final languageService = context.read<LanguageService>();
      
      for (var lang in languageService.all) {
        // Nur erstellen, wenn noch nicht vorhanden
        if (!_controllers.containsKey(lang)) {
           _controllers[lang] = List.generate(5, (_) => TextEditingController());
        }
      }
      
      _loadIds(); // Deine Lade-Methode
      _isInit = false; // Damit es nicht bei jedem Rebuild neu läuft
    }
  }
  
  @override
  void dispose() {
    for (var l in _controllers.values) {
      l.forEach((c) => c.dispose());
    }
    super.dispose();
  }

  Future<void> _loadIds() async {
    try {
      // ÄNDERUNG 2: Wir laden hier alle Sets (nicht nur IDs), damit wir die Namen anzeigen können.
      // Hinweis: Dein SupabaseService muss eine Methode haben, die List<Vocabulary> zurückgibt.
      // Falls sie anders heißt, bitte hier anpassen (z.B. fetchAllIds() -> fetchAllVocabulary()).
      final sets = await widget.supabaseService.fetchAllVocabulary(); 
      
      setState(() {
        _availableSets = sets;
        // Prüfen, ob die gewählte ID noch existiert
        if (!_availableSets.any((s) => s.id == _selectedId) || _availableSets.isEmpty) {
          _selectedId = null;
        }
      });
    } catch (e) {
      // Fehlerbehandlung (ggf. Loggen)
      debugPrint('Fehler beim Laden der Sets: $e');
    }
  }

  Future<void> _loadExistingSet(int id, LanguageService service) async {
    setState(() => _isLoading = true);
    _clearFields();
    try {
      final vocab = await widget.supabaseService.fetchVocabularyById(id);
      
      // Felder befüllen
      void fill(AppLanguage lang, List<String> words) {
        for (int i = 0; i < words.length && i < 5; i++) {
          _controllers[lang]![i].text = words[i];
        }
      }
      fill(service.lang1, vocab.wordsDe);
      fill(service.lang2, vocab.wordsEn);
      fill(service.lang3, vocab.wordsEs);

      setState(() => _message = 'Daten für ID $id geladen.');
    } catch (e) {
      setState(() => _message = 'Fehler: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    for (var l in _controllers.values) {
      l.forEach((c) => c.clear());
    }
  }

  Future<void> _save(LanguageService service) async {
    setState(() { _isLoading = true; _message = null; });

    // 1. Großes Datenobjekt bauen
    final Map<String, dynamic> data = {};

    // Helper: Liest Controller aus und schreibt in die korrekten Spaltennamen
    void collect(AppLanguage lang, String prefix, [String suffix = '']) {
      final list = _controllers[lang]!;
      for (int i = 0; i < 5; i++) {
        final text = list[i].text.trim();
        // Spaltenname bauen (z.B. Wort1 oder word_1_en)
        final key = suffix.isEmpty ? '$prefix${i+1}' : '${prefix}_${i+1}_$suffix';
        data[key] = text.isEmpty ? null : text;
      }
    }

    // Mapping anwenden
    collect(service.lang1, 'word', "ger");          // Wort1...
    collect(service.lang2, 'word', 'en');   // word_1_en...
    collect(service.lang3 , 'word', 'es');   // word_1_es...

    try {
      if (_mode == CreationMode.createNew) {
        if (data['word_1_ger'] == null) throw Exception('Bitte mindestens das erste deutsche Wort eingeben.');
        
        await widget.supabaseService.createVocabulary(data);
        setState(() => _message = 'Neues Set erfolgreich angelegt! ✅');
        _clearFields();
        _loadIds(); // Liste aktualisieren
      } else {
        if (_selectedId == null) throw Exception('Kein Wort gewählt.');
        await widget.supabaseService.updateVocabulary(_selectedId!, data);
        setState(() => _message = 'Set ID $_selectedId aktualisiert! ✅');
        _loadIds(); // Liste aktualisieren (falls sich Wörter geändert haben)
      }
    } on PostgrestException catch (e) {
      setState(() => _message = 'DB Fehler: ${e.message}');
    } catch (e) {
            setState(() => _message = 'Fehler: $e');
          } finally {
            setState(() => _isLoading = false);
          }
        }
        
        @override
        Widget build(BuildContext context) {

          final languageService = context.watch<LanguageService>();

          return Scaffold(
            appBar: AppBar(title: const Text('Trainer erstellen')),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Mode selection
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<CreationMode>(
                                title: const Text('Neues Set'),
                                value: CreationMode.createNew,
                                groupValue: _mode,
                                onChanged: (value) => setState(() => _mode = value!),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<CreationMode>(
                                title: const Text('Erweitern'),
                                value: CreationMode.extendExisting,
                                groupValue: _mode,
                                onChanged: (value) => setState(() => _mode = value!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

      
    // Dropdown for existing sets
                          if (_mode == CreationMode.extendExisting )
                              Builder(
                                builder: (context) {
                                  // Prüft, ob überhaupt Sets existieren, die angezeigt werden können.
                                  // Wir filtern hier bereits alle Sets heraus, die keine deutschen Worte haben.
                                  final validSets = _availableSets.where((set) => set.wordsDe.isNotEmpty).toList();

                                  if (validSets.isEmpty)
                                  {
                                    return Align(
                                      alignment: Alignment.topCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: const Text(
                                          'Keine Worte vorhanden',
                                          style: TextStyle(color: Colors.grey, fontSize: 24,)
                                        ),
                                      ),
                                    );
                                  }
                                  else
                                  {
                                    return Align(
                                      alignment: Alignment.topRight,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          DropdownButton<int>(
                                            hint: const Text('Wort zum bearbeiten wählen'),
                                            // Stellt sicher, dass die ID noch in der Liste der validen Sets existiert
                                            value: validSets.any((set) => set.id == _selectedId)
                                                ? _selectedId
                                                : null,
                                            items: validSets // <-- Wir verwenden jetzt die gefilterte Liste
                                                .map((set) => DropdownMenuItem(
                                                      value: set.id,
                                                      // Sicherer Zugriff, da wir Set.wordsDe.isNotEmpty geprüft haben
                                                      child: Text(set.wordsDe.first),
                                                    ))
                                                .toList(),
                                            onChanged: (id) {
                                              if (id != null) {
                                                setState(() => _selectedId = id);
                                                _loadExistingSet(id, context.read<LanguageService>());
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                                
                        
                        // Bedingte Anzeige der Eingabefelder (Input fields)
                        // Sie werden angezeigt, wenn:
                        // 1. Wir im Modus 'Neues Set' sind.
                        // 2. Wir im Modus 'Erweitern' sind UND bereits ein Set ausgewählt (_selectedId != null) wurde.
                        if (_mode == CreationMode.createNew || (_mode == CreationMode.extendExisting && _selectedId != null))
                        ...languageService.all.map((lang) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ..._controllers[lang]!
                                  .asMap()
                                  .entries
                                  .map((e) => TextField(
                                        controller: e.value
                                        //  decoration: InputDecoration(labelText: '${lang.label} ${e.key + 1}'),
                                      ))
                                  ,
                              const SizedBox(height: 16),
                            ],
                          );
                        }),

                        // Bedingte Anzeige des Speicher-Buttons (Save button)
                        if (_mode == CreationMode.createNew || (_mode == CreationMode.extendExisting && _selectedId != null))
                        ElevatedButton(onPressed: () => _save(context.read<LanguageService>()), child: const Text('Speichern')),
                                              
                        // Message
                        if (_message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(_message!, style: const TextStyle(color: Colors.red)),
                        ),
                                              
                        // Message
                        if (_message != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(_message!, style: const TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                  ),
          );
        }
      }


      // enum AppLanguage2 {
      //   german('Deutsch'),
      //   english('English'),
      //   spanish('Español');
      
      //   final String label;
      //   const AppLanguage2(this.label);
      // }
      
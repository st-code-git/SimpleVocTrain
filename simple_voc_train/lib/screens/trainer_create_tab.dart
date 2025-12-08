import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/vocabulary.dart';
import 'package:postgrest/postgrest.dart';

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
  final Map<AppLanguage2, List<TextEditingController>> _controllers = {};
  
  // ÄNDERUNG 1: Statt nur IDs speichern wir die ganzen Objekte für das Dropdown
  List<Vocabulary> _availableSets = [];
  int? _selectedId;
  
  String? _message;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var lang in AppLanguage2.values) {
      _controllers[lang] = List.generate(5, (_) => TextEditingController());
    }
    _loadIds();
  }
  
  @override
  void dispose() {
    _controllers.values.forEach((l) => l.forEach((c) => c.dispose()));
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
        if (!_availableSets.any((s) => s.id == _selectedId)) {
          _selectedId = null;
        }
      });
    } catch (e) {
      // Fehlerbehandlung (ggf. Loggen)
      debugPrint('Fehler beim Laden der Sets: $e');
    }
  }

  Future<void> _loadExistingSet(int id) async {
    setState(() => _isLoading = true);
    _clearFields();
    try {
      final vocab = await widget.supabaseService.fetchVocabularyById(id);
      
      // Felder befüllen
      void fill(AppLanguage2 lang, List<String> words) {
        for (int i = 0; i < words.length && i < 5; i++) {
          _controllers[lang]![i].text = words[i];
        }
      }
      fill(AppLanguage2.german, vocab.wordsDe);
      fill(AppLanguage2.english, vocab.wordsEn);
      fill(AppLanguage2.spanish, vocab.wordsEs);
      
      setState(() => _message = 'Daten für ID $id geladen.');
    } catch (e) {
      setState(() => _message = 'Fehler: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    _controllers.values.forEach((l) => l.forEach((c) => c.clear()));
  }

  Future<void> _save() async {
    setState(() { _isLoading = true; _message = null; });

    // 1. Großes Datenobjekt bauen
    final Map<String, dynamic> data = {};

    // Helper: Liest Controller aus und schreibt in die korrekten Spaltennamen
    void collect(AppLanguage2 lang, String prefix, [String suffix = '']) {
      final list = _controllers[lang]!;
      for (int i = 0; i < 5; i++) {
        final text = list[i].text.trim();
        // Spaltenname bauen (z.B. Wort1 oder word_1_en)
        final key = suffix.isEmpty ? '$prefix${i+1}' : '${prefix}_${i+1}_$suffix';
        data[key] = text.isEmpty ? null : text;
      }
    }

    // Mapping anwenden
    collect(AppLanguage2.german, 'word', "ger");          // Wort1...
    collect(AppLanguage2.english, 'word', 'en');   // word_1_en...
    collect(AppLanguage2.spanish, 'word', 'es');   // word_1_es...

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
                        if (_mode == CreationMode.extendExisting)
                          Align(
                          alignment: Alignment.topRight, // Erzwingt die Ausrichtung der Column nach links
                          child: Column(
                          //mainAxisSize: MainAxisSize.min,
                          //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButton<int>(
                                hint: const Text('Wort zum bearbeiten wählen'),
                                value: _selectedId,
                                items: _availableSets
                                    .map((set) => DropdownMenuItem(
                                          value: set.id,
                                          child: Text(set.wordsDe.first),
                                        ))
                                    .toList(),
                                onChanged: (id) {
                                  if (id != null) {
                                    setState(() => _selectedId = id);
                                    _loadExistingSet(id);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          )),
                        
                        // Input fields
                        ...AppLanguage2.values.map((lang) {
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
                                  .toList(),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                        
                        // Save button
                        ElevatedButton(onPressed: _save, child: const Text('Speichern')),
                        
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

      enum AppLanguage2 {
        german('Deutsch', 'de'),
        english('English', 'en'),
        spanish('Español', 'es');
      
        final String label;
        final String code;
        const AppLanguage2(this.label, this.code);
      }
      
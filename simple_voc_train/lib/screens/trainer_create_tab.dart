import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../services/language_service.dart'; 
import '../models/vocabulary.dart';
import '../models/app_language.dart';
import 'package:postgrest/postgrest.dart';
import 'package:dropdown_search/dropdown_search.dart';

enum CreationMode { createNew, extendExisting }

class TrainerCreateTab extends StatefulWidget {
  final SupabaseService supabaseService;
  const TrainerCreateTab({super.key, required this.supabaseService});

  @override
  State<TrainerCreateTab> createState() => _TrainerCreateTabState();
}

class _TrainerCreateTabState extends State<TrainerCreateTab> {
  CreationMode _mode = CreationMode.createNew;
  
  final Map<AppLanguage, List<TextEditingController>> _controllers = {};

  List<Vocabulary> _availableSets = [];
  int? _selectedId;
  
  String? _message;
  bool _isLoading = false;
  bool _isInit = true; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final languageService = context.watch<LanguageService>();

    for (var lang in languageService.all) {
      if (!_controllers.containsKey(lang)) {
         _controllers[lang] = List.generate(5, (_) => TextEditingController());
      }
    }

    if (_isInit) {
      _loadIds(); 
      _isInit = false; 
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
      final sets = await widget.supabaseService.fetchAllVocabulary(); 
      
      setState(() {
        _availableSets = sets;

        if (!_availableSets.any((s) => s.id == _selectedId) || _availableSets.isEmpty) {
          _selectedId = null;
        }
      });
    } catch (e) {

      debugPrint('Fehler beim Laden der Sets: $e');
    }
  }

  Future<void> _loadExistingSet(int id, LanguageService service) async {
    setState(() => _isLoading = true);
    _clearFields();
    try {
      final vocab = await widget.supabaseService.fetchVocabularyById(id);
      

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


    final Map<String, dynamic> data = {};

    void collect(AppLanguage lang, String prefix, [String suffix = '']) {
      final list = _controllers[lang]!;
      for (int i = 0; i < 5; i++) {
        final text = list[i].text.trim();

        final key = suffix.isEmpty ? '$prefix${i+1}' : '${prefix}_${i+1}_$suffix';
        data[key] = text.isEmpty ? null : text;
      }
    }

    collect(service.lang1, 'word', "ger");          
    collect(service.lang2, 'word', 'en');   
    collect(service.lang3 , 'word', 'es');  

    try {
      if (_mode == CreationMode.createNew) {
        if (data['word_1_ger'] == null) throw Exception('Bitte mindestens das erste deutsche Wort eingeben.');
        
        await widget.supabaseService.createVocabulary(data);
        setState(() => _message = 'Neues Set erfolgreich angelegt! ✅');
        _clearFields();
        _loadIds(); 
      } else {
        if (_selectedId == null) throw Exception('Kein Wort gewählt.');
        await widget.supabaseService.updateVocabulary(_selectedId!, data);
        setState(() => _message = 'Set ID $_selectedId aktualisiert! ✅');
        _loadIds(); 
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
  final currentlyLoading = _isLoading || languageService.isLoading;

  return Scaffold(
    appBar: AppBar(title: const Text('Trainer erstellen')),
    body: Stack(
  children: [
    // EBENE 1: Dein eigentlicher Inhalt (bleibt jetzt immer im Hintergrund bestehen)
    Positioned.fill(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // AbsorbPointer blockiert Klicks, solange geladen wird (damit man nicht doppelt klickt)
        child: AbsorbPointer(
          absorbing: currentlyLoading, 
          child: Column(
              children: [
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

                if (_mode == CreationMode.extendExisting)
                  Builder(
                    builder: (context) {
                      final mainLang = languageService.lang1;

                      // 1. Liste filtern
                      final validSets = _availableSets.where((set) {
                        return set.getWordsFor(mainLang, languageService).isNotEmpty;
                      }).toList();

                      if (validSets.isEmpty) {
                        return const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Keine Worte in Hauptsprache vorhanden',
                              style: TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                          ),
                        );
                      } else {
                        // 2. Sicheres selectedItem ermitteln
                        // Nutzt firstWhereOrNull (aus package:collection) oder manuelle Logik
                        final Vocabulary? currentSelection = _selectedId == null
                            ? null
                            : validSets.where((set) => set.id == _selectedId).firstOrNull;
                        
                        // Fallback: Wenn ID gesetzt ist, aber nicht in der Liste gefunden wurde -> null setzen
                        // (Verhindert Absturz durch veraltete IDs)

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: DropdownSearch<Vocabulary>(
                                  // 1. WICHTIG: Ein Key hilft Flutter, das Widget stabil zu halten
                                key: const ValueKey('vocab_dropdown'), 

                                items: (filter, loadProps) => validSets,

                                compareFn: (item, selectedItem) => item.id == selectedItem.id,

                                // 2. Deine Logik für die Auswahl (mit .where und .firstOrNull ist es sicher)
                                selectedItem: _selectedId == null
                                    ? null
                                    : validSets.where((set) => set.id == _selectedId).firstOrNull,

                                itemAsString: (set) {
                                  final words = set.getWordsFor(mainLang, languageService);
                                  return words.isNotEmpty ? words.first : "Unbekannt";
                                },

                                decoratorProps: const DropDownDecoratorProps(

                                  baseStyle: const TextStyle(
                                  fontSize: 16,              // <-- Schriftgröße
                                  // fontWeight: FontWeight.bold, // <-- Fett (Bold)
                                  // color: Colors.black87,     // Farbe
                                  ),

                                  decoration: InputDecoration(
                                    labelText: "Wort zum Bearbeiten wählen",

                                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                      


                                    hintText: "Suchen...",
                                    // filled: true,
                                    // fillColor: Colors.blueGrey ,
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),

                                // 3. DER FIX: ModalBottomSheet statt Menu
                                // Das verhindert den "AnimationController disposed" Absturz
                                popupProps: PopupProps.modalBottomSheet(
                                  showSearchBox: true,
                                  searchFieldProps: const TextFieldProps(
                                    decoration: InputDecoration(
                                      hintText: "Suchen...",
                                      prefixIcon: Icon(Icons.search),
                                      contentPadding: EdgeInsets.all(12),
                                    ),
                                  ),
                                  // Zieht das Fenster nur so hoch wie nötig (max 70% des Screens)
                                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                                  modalBottomSheetProps: const ModalBottomSheetProps(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                  ),
                                ),

                                onChanged: (set) async {
                                  if (set != null) {
       
                                                                        setState(() {
                                      _isLoading = true; 
                                      _selectedId = set.id;
                                    });
                                    
                                    // Lade die Daten
                                    await _loadExistingSet(set.id, languageService);

                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false; 
                                      });
                                    }
                                  }
                                },
                              )
                        );
                      }
                    },
                  ),

                if (_mode == CreationMode.createNew ||
                    (_mode == CreationMode.extendExisting && _selectedId != null))
                  ...languageService.all.map((lang) {
                     // (Dein bestehender Code hier ist okay)
                     final controllersForLang = _controllers[lang];
                     if (controllersForLang == null) return const SizedBox.shrink();
                     return Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(lang.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                         ...controllersForLang.asMap().entries.map((e) => Padding(
                               padding: const EdgeInsets.only(bottom: 8.0),
                               child: TextField(controller: e.value),
                             )),
                         const SizedBox(height: 16),
                       ],
                     );
                  }),

                if (_mode == CreationMode.createNew ||
                    (_mode == CreationMode.extendExisting && _selectedId != null))
                  ElevatedButton(
                    onPressed: () => _save(languageService),
                    child: const Text('Speichern'),
                  ),

                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(_message!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
  ),
    ),

    // EBENE 2: Lade-Indikator (wird nur angezeigt, wenn geladen wird)
    if (currentlyLoading)
      Positioned.fill(
        child: Container(
          color: Colors.black45,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ],
    ),  
    );
}
}

      
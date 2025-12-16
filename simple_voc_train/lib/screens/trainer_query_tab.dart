import 'package:flutter/material.dart';
import 'dart:math';
import '../models/vocabulary.dart';
import '../services/supabase_service.dart';
import '../screens/settings_page.dart';

enum RequiredAnswers { all, one }

class TrainerQueryTab extends StatefulWidget {
  final SupabaseService supabaseService;
  // currentLanguage wird hier nur noch als Standard für das Dropdown genutzt, falls gewünscht
  final AppLanguage currentLanguage; 

  const TrainerQueryTab({
    super.key,
    required this.supabaseService,
    required this.currentLanguage,
  });

  @override
  State<TrainerQueryTab> createState() => _TrainerQueryTabState();
}

class _TrainerQueryTabState extends State<TrainerQueryTab> {
  AppLanguage? _quizLanguage; 
  final Map<AppLanguage, TextEditingController> _answerControllers = {};
  
  Vocabulary? _currentVocabulary;
  String? _message;
  bool _isLoading = false;
  
  RequiredAnswers _requiredAnswers = RequiredAnswers.all;

  @override
  void initState() {
    super.initState();
    _quizLanguage = widget.currentLanguage; // Standard setzen
    for (var lang in AppLanguages.all) {
      _answerControllers[lang] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in _answerControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _startQuiz() async {
    if (_quizLanguage == null) {
      setState(() => _message = 'Bitte wählen Sie eine Abfragesprache.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Suche zufällige Vokabel...';
      _currentVocabulary = null;
      for (var c in _answerControllers.values) {
        c.clear();
      }
    });

    try {
      // Sichere Methode: Erst IDs laden, dann eine wählen
      final allIds = await widget.supabaseService.fetchAllIds();
      
      if (allIds.isEmpty || allIds.length == 1) {
        setState(() => _message = 'Keine Vokabeln in Vocabulary_Master gefunden.');
        return;
      }

      
      final randomId = allIds[Random().nextInt(allIds.length)];
      Vocabulary vocab = await widget.supabaseService.fetchVocabularyById(randomId);

      while(vocab.getWordsFor(_quizLanguage!).isEmpty) 
      {
        final randomId = allIds[Random().nextInt(allIds.length)];
        vocab = await widget.supabaseService.fetchVocabularyById(randomId);
      }

      // Prüfen, ob das Quellwort in der gewählten Sprache überhaupt existiert
      if (vocab.getWordsFor(_quizLanguage!).isEmpty) {
          setState(() => _message = 'ID $randomId geladen, aber kein Wort in ${_quizLanguage!} vorhanden. Versuchen Sie es erneut.');
          return;
      }


      setState(() {
        _currentVocabulary = vocab;
        _message = 'Übersetzen Sie das Wort in die fehlenden Sprachen.';
      });

    } catch (e) {
      setState(() => _message = 'Fehler: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkAnswer() {
    if (_currentVocabulary == null || _quizLanguage == null) return;
    
    // Wir prüfen alle Sprachen außer der Quellsprache
    final requiredLanguages = AppLanguages.all.where((l) => l != _quizLanguage).toList();
    
    int correctAnswers = 0;
    String feedback = '';

    for (var lang in requiredLanguages) {
      final userInput = _answerControllers[lang]!.text.trim().toLowerCase();
      // Hole die korrekten Lösungen aus dem lokalen Objekt
      final validWords = _currentVocabulary!.getWordsFor(lang).map((w) => w.toLowerCase()).toList();
      
      final isCorrect = validWords.contains(userInput);
      if (isCorrect) correctAnswers++;

      feedback += '${lang.toString()}: ${isCorrect ? "✅" : "❌"}\n';
    }

    bool passed = false;
    if (_requiredAnswers == RequiredAnswers.all) {
      passed = correctAnswers == requiredLanguages.length;
    } else {
      passed = correctAnswers >= 1;
    }

    setState(() {
      if (passed) {
        _message = 'Super! Alles richtig gelöst. (ID: ${_currentVocabulary!.id})';
      } else {
        _message = 'Leider nicht ganz.\n$feedback';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sprachen, die eingegeben werden müssen (alles außer Quizsprache)
    final answerLanguages = AppLanguages.all.where((l) => l != _quizLanguage).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Einstellungen
          DropdownButtonFormField<AppLanguage>(
            initialValue: _quizLanguage,
            decoration: const InputDecoration(labelText: 'Abfragewort (Sprache)'),
            items: AppLanguages.all.map((l) => DropdownMenuItem(value: l, child: Text(l.toString()))).toList(),
            onChanged: (val) => setState(() => _quizLanguage = val),
          ),
          Row(
            children: [
               Expanded(child: RadioListTile(
                 title: const Text('Alle lösen'), value: RequiredAnswers.all, 
                 groupValue: _requiredAnswers, onChanged: (v) => setState(() => _requiredAnswers = v!))),
               Expanded(child: RadioListTile(
                 title: const Text('Eins reicht'), value: RequiredAnswers.one, 
                 groupValue: _requiredAnswers, onChanged: (v) => setState(() => _requiredAnswers = v!))),
            ],
          ),
          const Divider(height: 30, thickness: 0, color: Colors.transparent,),
          FractionallySizedBox(
                widthFactor: 0.25, // Button nimmt 60% der Bildschirmbreite ein
                child: ElevatedButton(
                onPressed: _isLoading ? null : _startQuiz,
                child: const Text('Zufällige Vokabel abfragen'),
            ),
          ),
          const Divider(height: 30, color: Colors.transparent,),
          const Divider(height: 30),

          // Abfrage UI
          if (_currentVocabulary != null && _quizLanguage != null) ...[
             Container(
               padding: const EdgeInsets.all(16),
               color: Colors.blue.shade50,
               child: Column(
                 children: [
                   const Text('Was bedeutet:', style: TextStyle(color: Colors.grey)),
                   // Zeige das erste Wort der Quellsprache an
                   Text(
                     _currentVocabulary!.getWordsFor(_quizLanguage!).first, 
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                   ),
                 ],
               ),
             ),
             const SizedBox(height: 20),
             
             // Eingabefelder für die Zielsprachen
             ...answerLanguages.map((lang) => Padding(
               padding: const EdgeInsets.only(bottom: 10),
               child: TextField(
                 controller: _answerControllers[lang],
                 decoration: InputDecoration(
                   labelText: 'Übersetzung in ${lang.toString()}',
                   border: const OutlineInputBorder(),
                 ),
               ),
             )),

             ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
               onPressed: _checkAnswer,
               child: const Text('Prüfen'),
             )
          ],

          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(_message!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
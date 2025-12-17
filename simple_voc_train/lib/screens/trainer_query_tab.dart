import 'package:flutter/material.dart';
import 'dart:math';
import '../models/vocabulary.dart';
import '../models/app_language.dart';
import '../services/supabase_service.dart';
import '../services/language_service.dart';
import 'package:provider/provider.dart';


enum RequiredAnswers { all, one }

class TrainerQueryTab extends StatefulWidget {
  final SupabaseService supabaseService;
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
    _quizLanguage = widget.currentLanguage; // set standard
     final languageService = context.read<LanguageService>();
    for (var lang in languageService.all) {
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

  Future<void> _startQuiz(LanguageService service) async {
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
      final allIds = await widget.supabaseService.fetchAllIds();
      
      if (allIds.isEmpty || allIds.length == 1) {
        setState(() => _message = 'Keine Vokabeln in Vocabulary_Master gefunden.');
        return;
      }

      
      final randomId = allIds[Random().nextInt(allIds.length)];
      Vocabulary vocab = await widget.supabaseService.fetchVocabularyById(randomId);

      while(vocab.getWordsFor(_quizLanguage!, service).isEmpty) 
      {
        final randomId = allIds[Random().nextInt(allIds.length)];
        vocab = await widget.supabaseService.fetchVocabularyById(randomId);
      }

      if (vocab.getWordsFor(_quizLanguage!, service).isEmpty) {
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

  void _checkAnswer(LanguageService service) {
    if (_currentVocabulary == null || _quizLanguage == null) return;
    
    final requiredLanguages = service.all.where((l) => l != _quizLanguage).toList();
    
    int correctAnswers = 0;
    String feedback = '';

    for (var lang in requiredLanguages) {
      final userInput = _answerControllers[lang]!.text.trim().toLowerCase();
      final validWords = _currentVocabulary!.getWordsFor(lang, service).map((w) => w.toLowerCase()).toList();
      
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
  final languageService = context.watch<LanguageService>();

  // 2. Lade-Schutz
  if (languageService.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  AppLanguage selectedValue = _quizLanguage ?? languageService.lang1;

  if (!languageService.all.contains(selectedValue)) {
    selectedValue = languageService.all.first;
  }

  final answerLanguages = languageService.all.where((l) => l != selectedValue).toList();

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<AppLanguage>(
          value: selectedValue, 
          decoration: const InputDecoration(labelText: 'Abfragewort (Sprache)'),
          items: languageService.all.map((l) => DropdownMenuItem(
            value: l, 
            child: Text(l.toString())
          )).toList(),
          onChanged: (val) {
            setState(() => _quizLanguage = val);
          },
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
              widthFactor: 0.25,
              child: ElevatedButton(
              onPressed: _isLoading ? null : () => _startQuiz(languageService),
              child: const Text('Zufällige Vokabel abfragen'),
          ),
        ),
        
        const Divider(height: 30, color: Colors.transparent,),
        const Divider(height: 30),

        if (_currentVocabulary != null) ...[
           Container(
             padding: const EdgeInsets.all(16),
             color: Colors.blue.shade50,
             child: Column(
               children: [
                 const Text('Was bedeutet:', style: TextStyle(color: Colors.grey)),
                 Text(
                   _currentVocabulary!.getWordsFor(selectedValue, languageService).first, 
                   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                 ),
               ],
             ),
           ),
           const SizedBox(height: 20),

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
             onPressed: () => _checkAnswer(languageService),
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
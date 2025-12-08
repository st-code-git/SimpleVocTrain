import '../services/supabase_service.dart'; // Import für AppLanguage

class Vocabulary {
  final int id;
  // Wir speichern die Wörter als Listen, das macht die Verarbeitung leichter
  final List<String> wordsDe;
  final List<String> wordsEn;
  final List<String> wordsEs;

  Vocabulary({
    required this.id,
    required this.wordsDe,
    required this.wordsEn,
    required this.wordsEs,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    // Hilfsfunktion, um 5 Spalten in eine saubere Liste zu packen (ohne null/leer)
    List<String> extractWords(String prefix, [String suffix = '']) {
      final list = <String>[];
      for (int i = 1; i <= 5; i++) {
        // Baut den Spaltennamen: z.B. "Wort1" oder "word_1_en"
        final key = suffix.isEmpty ? '$prefix$i' : '${prefix}_${i}_$suffix';
        final val = json[key] as String?;
        if (val != null && val.trim().isNotEmpty) {
          list.add(val.trim());
        }
      }
      return list;
    }

    return Vocabulary(
      id: json['id'] as int,
      // Mapping auf Ihre spezifischen Spaltennamen:
      wordsDe: extractWords('word', 'ger'),          // Mappt auf Wort1 ... Wort5
      wordsEn: extractWords('word', 'en'),    // Mappt auf word_1_en ... word_5_en
      wordsEs: extractWords('word', 'es'),    // Mappt auf word_1_es ... word_5_es
    );
  }

  // Gibt die Wörter für eine bestimmte Sprache zurück
  List<String> getWordsFor(AppLanguage1 lang) {
    switch (lang) {
      case AppLanguage1.german: return wordsDe;
      case AppLanguage1.english: return wordsEn;
      case AppLanguage1.spanish: return wordsEs;
    }
  }
}
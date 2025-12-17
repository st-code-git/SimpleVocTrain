import '../models/app_language.dart';
import '../services/language_service.dart';

class Vocabulary {
  final int id;
  final List<String> wordsDe;
  final List<String> wordsEn;
  final List<String> wordsEs;

  Vocabulary({
    required this.id,
    required this.wordsDe,
    required this.wordsEn,
    required this.wordsEs,
  });

  //Builds a Vocabulary object from a JSON map (received from Supabase)
  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    List<String> extractWords(String prefix, [String suffix = '']) {
      final list = <String>[];
      for (int i = 1; i <= 5; i++) {
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

      wordsDe: extractWords('word', 'ger'),          
      wordsEn: extractWords('word', 'en'),    
      wordsEs: extractWords('word', 'es'),   
    );
  }


  List<String> getWordsFor(AppLanguage lang, LanguageService service) {
    if (lang == service.lang1) {
      return wordsDe; // oder wie deine Liste für Slot 1 heißt
    } else if (lang == service.lang2) {
      return wordsEn; // für Slot 2
    } else if (lang == service.lang3) {
      return wordsEs; // für Slot 3
    } else {
      return [];
    }
  }
}
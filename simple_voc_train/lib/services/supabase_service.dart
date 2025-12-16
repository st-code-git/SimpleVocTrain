import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary.dart';

// Enum definieren (wird hier und im Model genutzt)
// enum AppLanguage1 {
//   german('Deutsch'),
//   english('Englisch'),
//   spanish('Spanisch');

//   final String displayName;
//   const AppLanguage1(this.displayName);
// }

class SupabaseService {
  final SupabaseClient supabase;
  
  // Zentraler Tabellenname
  static const String tableName = 'Vocabulary_Master';

  SupabaseService(this.supabase);

  // 1. Zählen (für Random ID)
  Future<int> getVocabularyCount() async {
    return await supabase.from(tableName).count();
  }

  // 2. Alle IDs holen (für Dropdown-Liste beim Bearbeiten)
  Future<List<int>> fetchAllIds() async {
    final response = await supabase.from(tableName).select('id').order('id');
    return (response as List).map((map) => map['id'] as int).toList();
  }

  // 3. Eine komplette Vokabelzeile laden
  Future<Vocabulary> fetchVocabularyById(int id) async {
    final response = await supabase
        .from(tableName)
        .select() // Lädt automatisch alle Spalten (*)
        .eq('id', id)
        .single();
    
    return Vocabulary.fromJson(response);
  }

  // 4. Anlegen (Insert)
  Future<void> createVocabulary(Map<String, dynamic> data) async {
    await supabase.from(tableName).insert(data);
  }

  // 5. Aktualisieren (Update)
  Future<void> updateVocabulary(int id, Map<String, dynamic> data) async {
    await supabase.from(tableName).update(data).eq('id', id);
  }

  Future<List<Vocabulary>> fetchAllVocabulary() async {
    final response = await supabase
        .from(tableName)
        .select(); // Lädt automatisch alle Spalten (*)
    
    return response.map<Vocabulary>((json) => Vocabulary.fromJson(json)).toList();;
  }

  //Signout Methode
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
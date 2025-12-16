import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary.dart';
import '../screens/settings_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class SupabaseService {
  // 1️⃣ Privater Konstruktor
  SupabaseService._internal();

  // 2️⃣ Statische Singleton-Instanz
  static final SupabaseService _instance = SupabaseService._internal();

  // 3️⃣ Getter für globale Nutzung
  static SupabaseService get instance => _instance;

  // 4️⃣ Supabase Client (nullable bis init abgeschlossen)
  SupabaseClient? client;

  // 5️⃣ Initialisierung
  Future<void> init() async {
    try {
      // dotenv laden
      await dotenv.load(fileName: "assets/env");

      // Supabase initialisieren
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );

      // Client erst nach Initialisierung setzen
      client = Supabase.instance.client;

    } catch (e) {
      print("Fehler beim Start: $e");
    }
  }

  // 6️⃣ Optional: Helfer, um den Client sicher zu holen
  SupabaseClient get safeClient {
    if (client == null) {
      throw Exception(
          "SupabaseClient ist noch nicht initialisiert. Rufe zuerst init() auf!");
    }
    return client!;
  }

  
  //final SupabaseClient supabase;
  
   //Zentraler Tabellenname
  static const String tableName = 'Vocabulary_Master';

  //SupabaseService(this.supabase);

  // 1. Zählen (für Random ID)
  Future<int> getVocabularyCount() async {
    return await client!.from(tableName).count();
  }

  // 2. Alle IDs holen (für Dropdown-Liste beim Bearbeiten)
  Future<List<int>> fetchAllIds() async {
    final response = await client!.from(tableName).select('id').order('id');
    return (response as List).map((map) => map['id'] as int).toList();
  }

  // 3. Eine komplette Vokabelzeile laden
  Future<Vocabulary> fetchVocabularyById(int id) async {
    final response = await client!
        .from(tableName)
        .select() // Lädt automatisch alle Spalten (*)
        .eq('id', id)
        .single();
    
    return Vocabulary.fromJson(response);
  }

  // 4. Anlegen (Insert)
  Future<void> createVocabulary(Map<String, dynamic> data) async {
    await client!.from(tableName).insert(data);
  }

  // 5. Aktualisieren (Update)
  Future<void> updateVocabulary(int id, Map<String, dynamic> data) async {
    await client!.from(tableName).update(data).eq('id', id);
  }

  Future<List<Vocabulary>> fetchAllVocabulary() async {
    final response = await client!
        .from(tableName)
        .select(); // Lädt automatisch alle Spalten (*)
    
    return response.map<Vocabulary>((json) => Vocabulary.fromJson(json)).toList();
  }

  //Signout Methode
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<AppLanguagesData?> loadUserLanguages() async {
    final user = client!.auth.currentUser;
    if (user == null) return null;

    try {
      // select(...) liefert direkt eine Liste
      final List<Map<String, dynamic>> result = await client!
          .from('user_config')
          .select('lang_1, lang_2, lang_3')
          .eq('uid', user.id)
          .limit(1);

      if (result.isEmpty) return null;

      final data = result.first;
      return AppLanguagesData(
        language1: data['lang_1'] ?? '',
        language2: data['lang_2'] ?? '',
        language3: data['lang_3'] ?? '',
      );
    } catch (e) {
      print("Fehler beim Laden der Sprachen: $e");
      return null;
    }
  }

//  Future<List<AppLanguage>> loadUserLanguages() async {
//   final supabase = Supabase.instance.client;
//   final user = supabase.auth.currentUser;

//   if (user == null) return []; // Kein eingeloggter User

//   final response = await supabase
//       .from('user_config')
//       .select('lang_1, lang_2, lang_3')
//       .eq('uid', user.id)
//       .maybeSingle();

//   if (response == null) return []; // Keine Config gefunden

//   return [
//     AppLanguage.fromMap({'label': response['lang_1']}),
//     AppLanguage.fromMap({'label': response['lang_2']}),
//     AppLanguage.fromMap({'label': response['lang_3']}),
//   ];
// }

  Future<bool> saveUserLanguages({
    required AppLanguage lang1,
    required AppLanguage lang2,
    required AppLanguage lang3,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return false; // Kein eingeloggter User

    final Map<String, dynamic> updates = {
      'lang_1': lang1.toMap()['label']?.toString() ?? '',
      'lang_2': lang2.toMap()['label']?.toString() ?? '',
      'lang_3': lang3.toMap()['label']?.toString() ?? '',
    };

    //await SupabaseService.instance.init();

    await client!
        .from('user_config')
        .update(updates)
        .eq('uid', user.id);

    return true;
  }


}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary.dart';
import '../models/app_language.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  
  // 1. Privater Konstruktor
  SupabaseService._internal();

  // 2. Singleton Instance
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseService get instance => _instance;

  // 3. Initialisierung (nur Env laden und Supabase starten)
  Future<void> init() async {
    try {
      await dotenv.load(fileName: "assets/env");

      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );
      // HIER KEIN client = ... MEHR SETZEN!
      
    } catch (e) {
      print("Fehler beim Start: $e");
    }
  }

  // 4. Der Getter greift IMMER auf das aktuelle Original zu
  // Das verhindert, dass deine Variable 'null' ist, während Supabase eigentlich bereit wäre.
  SupabaseClient get client {
    return Supabase.instance.client;
  }

   //Central table name
  static const String tableName = 'Vocabulary_Master';

  Future<int> getVocabularyCount() async {
    return await client!.from(tableName).count();
  }

  Future<List<int>> fetchAllIds() async {
    final response = await client!.from(tableName).select('id').order('id');
    return (response as List).map((map) => map['id'] as int).toList();
  }

  Future<Vocabulary> fetchVocabularyById(int id) async {
    final response = await client!
        .from(tableName)
        .select() 
        .eq('id', id)
        .single();
    
    return Vocabulary.fromJson(response);
  }

  Future<void> createVocabulary(Map<String, dynamic> data) async {
    await client!.from(tableName).insert(data);
  }

  Future<void> updateVocabulary(int id, Map<String, dynamic> data) async {
    await client!.from(tableName).update(data).eq('id', id);
  }

  Future<List<Vocabulary>> fetchAllVocabulary() async {
    final response = await client!
        .from(tableName)
        .select(); 
    
    return response.map<Vocabulary>((json) => Vocabulary.fromJson(json)).toList();
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<AppLanguagesData?> loadUserLanguages() async {
    final user = client!.auth.currentUser;
    if (user == null) return null;

    try {
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

  Future<bool> saveUserLanguages({
    required AppLanguage lang1,
    required AppLanguage lang2,
    required AppLanguage lang3,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return false; // No user logged in

    final Map<String, dynamic> updates = {
      'lang_1': lang1.toMap()['label']?.toString() ?? '',
      'lang_2': lang2.toMap()['label']?.toString() ?? '',
      'lang_3': lang3.toMap()['label']?.toString() ?? '',
    };

    await client!
        .from('user_config')
        .update(updates)
        .eq('uid', user.id);

    return true;
  }

  Future<List<String>> checkDuplicates(Map<String, dynamic> data) async {
    final query = client!.from(tableName).select();

    data.forEach((key, value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        query.eq(key, value);
      }
    });

    final response = await query.select();

    final duplicates = <String>{};

    for (var record in response) {
      data.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          if (record[key] == value) {
            duplicates.add(key);
          }
        }
      });
    }

    return duplicates.toList();
  }

  Future<void> deleteVocabulary(int id) async {
    await client!.from(tableName).delete().eq('id', id);
  }


}
import 'package:flutter/material.dart';
import 'package:simple_voc_train/screens/password_reset_screen.dart';
import '../services/supabase_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});


  @override
  State<SettingsPage> createState() => _SettingsPageState();
}


// --- Sprachklassen ---
class AppLanguage {
  String label;

  AppLanguage({required this.label});

  // 🔁 Factory-Konstruktor: erstellt eine AppLanguage aus einer Map
  factory AppLanguage.fromMap(Map<String, dynamic> data) {
    return AppLanguage(
      label: data['label'] ?? 'Deutsch', // Fallback, falls nichts drinsteht
    );
  }

  /// 🔄 Wandelt das Objekt wieder in eine Map um
  Map<String, dynamic> toMap() {
    return {
      'label': label,
    };
  }

  @override
  String toString() {
    return label;
  }
}

// class AppLanguages {


//    static final language_1 = AppLanguage(label: 'Deutsch');
//    static final language_2 = AppLanguage(label: 'English');
//    static final language_3 = AppLanguage(label: 'Español');

//    static List<AppLanguage> get all => [language_1, language_2, language_3];
  
//  }

class AppLanguages {
  // Statische Felder (Default-Werte)
  static AppLanguage language_1 = AppLanguage(label: 'Deutsch');
  static AppLanguage language_2 = AppLanguage(label: 'English');
  static AppLanguage language_3 = AppLanguage(label: 'Español');

  // Getter für alle Sprachen
  static List<AppLanguage> get all => [language_1, language_2, language_3];

  AppLanguages._(); // privater Konstruktor, keine Instanz nötig

  /// Lädt die User-Sprachen aus der DB und überschreibt die statischen Felder
  static Future<void> loadUserLanguagesFromDb() async {
    final data = await SupabaseService.instance.loadUserLanguages();

    // Fallback auf Default-Werte, falls kein Datensatz vorhanden
    final langs = data ??
        AppLanguagesData(
          language1: language_1.label,
          language2: language_2.label,
          language3: language_3.label,
        );

    // Überschreibt die statischen Felder dynamisch
    language_1 = AppLanguage(label: langs.language1);
    language_2 = AppLanguage(label: langs.language2);
    language_3 = AppLanguage(label: langs.language3);
  }
}






 class AppLanguagesData {
   String language1;
   String language2;
   String language3;

   AppLanguagesData({
     required this.language1,
     required this.language2,
     required this.language3,
   });

  
}


class _SettingsPageState extends State<SettingsPage> {
  late AppLanguagesData _languages;
  late final TextEditingController _lang1Controller;
  late final TextEditingController _lang2Controller;
  late final TextEditingController _lang3Controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserLanguages();
    AppLanguages.loadUserLanguagesFromDb();
  }

  Future<void> _loadUserLanguages() async {
    final data = await SupabaseService.instance.loadUserLanguages();

    // Falls kein Datensatz existiert, Default-Werte
    _languages = data ??
        AppLanguagesData(
          language1: 'Deutsch',
          language2: 'English',
          language3: 'Español',
        );

    _lang1Controller = TextEditingController(text: _languages.language1);
    _lang2Controller = TextEditingController(text: _languages.language2);
    _lang3Controller = TextEditingController(text: _languages.language3);

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _lang1Controller.dispose();
    _lang2Controller.dispose();
    _lang3Controller.dispose();
    super.dispose();
  }

  

  void _save() async {
    _languages.language1 = _lang1Controller.text;
    _languages.language2 = _lang2Controller.text;
    _languages.language3 = _lang3Controller.text;

    final success = await SupabaseService.instance.saveUserLanguages(
      lang1: AppLanguage(label: _languages.language1),
      lang2: AppLanguage(label: _languages.language2),
      lang3: AppLanguage(label: _languages.language3),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Sprachen gespeichert!' : 'Fehler beim Speichern'),
      ),
    );
  }


// --- Settings Page State ---
// class _SettingsPageState extends State<SettingsPage> {
//   final _languages = AppLanguagesData(
//     language1: 'Deutsch',
//     language2: 'English',
//     language3: 'Español',
//   );

//   late final TextEditingController _lang1Controller;
//   late final TextEditingController _lang2Controller;
//   late final TextEditingController _lang3Controller;

//   @override
//   void initState() {
//     super.initState();

//     _lang1Controller = TextEditingController(text: _languages.language1);
//     _lang2Controller = TextEditingController(text: _languages.language2);
//     _lang3Controller = TextEditingController(text: _languages.language3);
//   }

//   @override
//   void dispose() {
//     _lang1Controller.dispose();
//     _lang2Controller.dispose();
//     _lang3Controller.dispose();
//     super.dispose();
//   }

  

//   void _save() async {
//     setState(() {
//        _languages.language1 = _lang1Controller.text;
//        _languages.language2 = _lang2Controller.text;
//        _languages.language3 = _lang3Controller.text;
//      });

//     // Speichern
//     try {
//     final success = await SupabaseService.instance.saveUserLanguages(
//       lang1: AppLanguage(label: _languages.language1 ),
//       lang2: AppLanguage(label: _languages.language2 ),
//       lang3: AppLanguage(label: _languages.language3 ),
//     );
//     if (success) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Sprachen gespeichert!')),
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Fehler beim Speichern')),
//     );
//   }
    
//     } catch (e) {
//       print('Fehler beim Speichern der Sprachen: $e');
//     }
//   }


  // void _load() async {
  //   try {
  //     final languages = await SupabaseService.instance.loadUserLanguages();
  //     if (languages.length >= 3) {
  //       setState(() {
  //         _lang1Controller.text = languages[0].label;
  //         _lang2Controller.text = languages[1].label;
  //         _lang3Controller.text = languages[2].label;
  //       });
  //     }
  //   } catch (e) {
  //     print('Fehler beim Laden der Sprachen: $e');
  //   }
  // }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Benutzerkonfiguration')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Passwort ändern ---
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Passwort ändern'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PasswordResetScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // --- Sprachfelder ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildField('Sprache 1', _lang1Controller),
                  _buildField('Sprache 2', _lang2Controller),
                  _buildField('Sprache 3', _lang3Controller),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async { _save(); },
                      child: const Text('Speichern'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
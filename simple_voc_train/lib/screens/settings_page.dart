import 'package:flutter/material.dart';
import 'package:simple_voc_train/screens/password_reset_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// --- Sprachklassen ---
class AppLanguage {
  String label;

  AppLanguage({required this.label});
}

class AppLanguages {
  static final language_1 = AppLanguage(label: 'Deutsch');
  static final language_2 = AppLanguage(label: 'English');
  static final language_3 = AppLanguage(label: 'Español');

  static List<AppLanguage> get all => [language_1, language_2, language_3];
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

// --- Settings Page State ---
class _SettingsPageState extends State<SettingsPage> {
  final _languages = AppLanguagesData(
    language1: 'Deutsch',
    language2: 'English',
    language3: 'Español',
  );

  late final TextEditingController _lang1Controller;
  late final TextEditingController _lang2Controller;
  late final TextEditingController _lang3Controller;

  @override
  void initState() {
    super.initState();
    _lang1Controller = TextEditingController(text: _languages.language1);
    _lang2Controller = TextEditingController(text: _languages.language2);
    _lang3Controller = TextEditingController(text: _languages.language3);
  }

  @override
  void dispose() {
    _lang1Controller.dispose();
    _lang2Controller.dispose();
    _lang3Controller.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _languages.language1 = _lang1Controller.text;
      _languages.language2 = _lang2Controller.text;
      _languages.language3 = _lang3Controller.text;
    });

    // Hier DB-Speicherlogik einfügen
    //
    // Zum Testen einfach eine Ausgabe in der Konsole

    print('Gespeichert: ${_languages.language1}, ${_languages.language2}, ${_languages.language3}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sprachen gespeichert!')),
    );
  }

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
                      onPressed: _save,
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
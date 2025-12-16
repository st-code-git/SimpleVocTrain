import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider Paket nötig
import '../services/language_service.dart';
import 'password_reset_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Controller
  late TextEditingController _lang1Controller;
  late TextEditingController _lang2Controller;
  late TextEditingController _lang3Controller;

  @override
  void initState() {
    super.initState();
    // Wir holen uns EINMALIG die aktuellen Werte aus dem Service für die Textfelder
    final service = context.read<LanguageService>();
    
    _lang1Controller = TextEditingController(text: service.lang1.label);
    _lang2Controller = TextEditingController(text: service.lang2.label);
    _lang3Controller = TextEditingController(text: service.lang3.label);
  }

  @override
  void dispose() {
    _lang1Controller.dispose();
    _lang2Controller.dispose();
    _lang3Controller.dispose();
    super.dispose();
  }

  void _save() async {
    // Zugriff auf den Service zum Speichern
    final service = context.read<LanguageService>();
    
    final success = await service.updateLanguages(
      _lang1Controller.text,
      _lang2Controller.text,
      _lang3Controller.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Sprachen gespeichert!' : 'Fehler beim Speichern'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
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
    // Optional: Falls Sie auf Ladezustände im UI reagieren wollen
    // final isLoading = context.select<LanguageService, bool>((s) => s.isLoading);

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
                      onPressed: _save, // Ruft _save auf
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
// Datei: settings_page.dart

import 'package:flutter/material.dart';
import 'package:simple_voc_train/screens/password_reset_screen.dart';
//import 'password_change_page.dart'; // Importiere die Passwortseite

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Liste der verfügbaren Sprachen
  final List<String> availableLanguages = ['Deutsch', 'Englisch', 'Französisch'];
  
  // Aktuell ausgewählte Sprache (Initialwert)
  String? _selectedLanguage = 'Deutsch'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Benutzerkonfiguration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[

          // --- 1. Passwort ändern Link/Button ---
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.lock),
              title: Text('Passwort ändern'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigiere zur Passwortänderungs-Seite
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PasswordResetScreen(),
                  ),
                );
              },
            ),
          ),
          
          Divider(height: 32), // Visuelle Trennung

          // --- 2. Sprachkonfiguration Optionsmenü ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'App-Sprache konfigurieren',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Sprache wählen',
                  border: InputBorder.none, // Entfernt den standardmäßigen Rahmen
                ),
                value: _selectedLanguage,
                items: availableLanguages.map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue;
                    // Hier würden Sie die Logik zur Speicherung der neuen Sprache hinzufügen
                    print('Neue Sprache ausgewählt: $_selectedLanguage');
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
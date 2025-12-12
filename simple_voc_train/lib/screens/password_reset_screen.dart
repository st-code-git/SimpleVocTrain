import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  // Controller für das Textfeld
  final TextEditingController _passwordController = TextEditingController();
  
  // Status für den Lade-Spinner
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    // 1. Einfache Validierung
    final password = _passwordController.text.trim();
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Das Passwort muss mindestens 6 Zeichen lang sein.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Dein Code: User Update in Supabase
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password: password,
        ),
      );

      if (!mounted) return;

      // 3. Erfolg: Feedback geben und zum Dashboard leiten
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwort erfolgreich gespeichert!'),
          backgroundColor: Colors.green,
        ),
      );

      // WICHTIG: pushNamedAndRemoveUntil löscht den "Zurück"-Button.
      // Man soll nach dem Speichern nicht zurück zum Reset-Screen können.
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

    } catch (e) {
      if (!mounted) return;
      // 4. Fehlerbehandlung
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwort festlegen'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400), // Damit es im Web nicht zu breit wird
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Willkommen!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Bitte erstelle ein neues Passwort für deinen Account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              
              // Eingabefeld
              TextField(
                controller: _passwordController,
                obscureText: true, // Passwort verstecken
                decoration: const InputDecoration(
                  labelText: 'Neues Passwort',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),

              // Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      )
                    : const Text('Passwort speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
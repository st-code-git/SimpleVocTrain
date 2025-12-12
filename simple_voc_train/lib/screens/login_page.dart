import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller für die Textfelder
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


 
  // Die signIn Methode, die du brauchst!
  Future<void> _signIn() async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;

    // ERFOLG: Weiterleiten zur Hauptseite und Login vergessen
      Navigator.of(context).pushReplacementNamed('/home');
      
    } on AuthException catch (e) {
      // Fehler anzeigen (z.B. falsches Passwort)
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unbekannter Fehler')));
    }
  }

  Future<void> _updatePassword() async {
  try {
    // Das aktualisiert den aktuell eingeloggten User (der durch den Invite Link drin ist)
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(
        password: _passwordController.text,
      ),
    );
    // Erfolg: Weiterleiten zum Dashboard oder Success-Message
    print("Passwort erfolgreich gesetzt!");
  } catch (e) {
    print("Fehler: $e");
  }
}

@override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      
      if (event == AuthChangeEvent.passwordRecovery) {
        // WICHTIG: Hierhin navigieren, wenn der User per Link kommt!
        Navigator.of(context).pushNamed('/update-password-page'); 
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Einloggen'),
            ),
          ],
        ),
      ),
    );
  }
}
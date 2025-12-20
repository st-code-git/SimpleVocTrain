import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/home');
      
    } on AuthException catch (e) {

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unbekannter Fehler')));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


@override
Widget build(BuildContext context) {
  // Center & SingleChildScrollView machen das Layout sicher für Web & Mobile
  return Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            // 1️⃣ Überschrift
            const Text(
              'simplevoc',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40), // Statt Spacer

            // 2️⃣ Animation
            // Wir prüfen sicherheitshalber, ob das Asset geladen werden kann.
            // Falls der 404 Fehler bleibt, stürzt die App hier nicht ab.
            SizedBox(
              height: 200,
              child: Lottie.asset(
                'assets/animations/christmasTree.json',
                fit: BoxFit.contain,
                // Optional: Zeige Fehler, falls Datei nicht gefunden wird
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red, size: 50);
                },
              ),
            ),

            const SizedBox(height: 40), // Statt Spacer

            // 3️⃣ Login-Felder
            // Wir beschränken die Breite für Desktop (sieht schöner aus)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Passwort',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Einloggen'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60), // Statt Spacer

            // 4️⃣ Disclaimer
            const Text(
              'Diese Website wird ausschließlich privat und nicht geschäftsmäßig betrieben.\n'
              'Es findet keine kommerzielle Nutzung oder Datenverarbeitung zu Werbezwecken statt.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  
}
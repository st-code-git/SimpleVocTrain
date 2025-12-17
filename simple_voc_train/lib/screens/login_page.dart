import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // 1️⃣ Oben
          Padding(
            padding: const EdgeInsets.only(top: 96.0),
            child: Text(
              'simplevoc - einfach Vokabeln lernen',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),


          Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
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

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Diese Website wird ausschließlich privat und nicht geschäftsmäßig betrieben.\n'
              'Es findet keine kommerzielle Nutzung oder Datenverarbeitung zu Werbezwecken statt.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  
}
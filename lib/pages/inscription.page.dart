import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizinteractif/services/auth.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InscriptionPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const InscriptionPage({super.key, required this.onThemeChanged});

  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isDarkMode = false;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    widget.onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _onInscrire(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      // Inscription via Firebase
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Stocker l'utilisateur dans SharedPreferences
      await AuthService.registerUser(email);

      // Ne PAS définir 'connect' à true
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', email); // Optionnel
      await prefs.remove('connect'); // S'assurer que 'connect' est supprimé
      await AuthService.debugSharedPreferences();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie')),
      );
      debugPrint('Navigation vers /login');
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      String message = 'Une erreur est survenue';
      if (e.code == 'email-already-in-use') {
        message = 'Cet email est déjà utilisé.';
      } else if (e.code == 'invalid-email') {
        message = 'Email invalide.';
      } else if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Inscription',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            prefixIcon: Icon(Icons.email),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            prefixIcon: Icon(Icons.lock),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thème : Clair',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Switch(
                              value: _isDarkMode,
                              onChanged: _toggleTheme,
                              activeColor: Colors.blue.shade600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _onInscrire(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Inscription',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'J\'ai déjà un compte',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

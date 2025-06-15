import 'package:flutter/material.dart';
import 'package:quizinteractif/services/auth.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController txtLogin = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  Future<void> _checkIfAlreadyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isConnected = prefs.getBool('connect') ?? false;
    final currentUser = prefs.getString('currentUser');

    if (isConnected && currentUser != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/accueil');
      }
    }
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    final email = txtLogin.text.trim();
    final password = txtPassword.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      final isAuthenticated = await AuthService.authenticateUser(email, password);
      if (isAuthenticated) {
        debugPrint('Connexion réussie pour : $email');
        await AuthService.debugSharedPreferences();
        Navigator.pushReplacementNamed(context, '/accueil');
      } else {
        throw FirebaseAuthException(code: 'auth-failed', message: 'Échec de l\'authentification');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur: ${e.message}';
      if (e.code == 'user-not-found') {
        message = 'Aucun utilisateur trouvé pour cet email.';
      } else if (e.code == 'wrong-password') {
        message = 'Mot de passe incorrect.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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
                  AppLocalizations.of(context)!.welcomeMessage,
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
                          controller: txtLogin,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: txtPassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _signInWithEmailAndPassword(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Connexion',
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
                    Navigator.pushNamed(context, '/inscription');
                  },
                  child: Text(
                    "Je n'ai pas de compte",
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizinteractif/services/auth.service.dart';

class ScoresPage extends StatefulWidget {
  const ScoresPage({super.key});

  @override
  State<ScoresPage> createState() => _ScoresPageState();
}
class _ScoresPageState extends State<ScoresPage> {
  Map<String, double> _scores = {};
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }
  Future<void> _loadScores() async {
    debugPrint('Démarrage du chargement des scores...');
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('currentUser');
    debugPrint('Utilisateur connecté : $_username');
    if (_username != null) {
      final user = await AuthService.getUser(_username!);
      if (user != null) {
        debugPrint('Utilisateur trouvé : ${user.username}, scores : ${user.scores}');
        setState(() {
          _scores = user.scores;
        });
      } else {
        debugPrint('Utilisateur non trouvé dans AuthService.getUser');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur : Utilisateur non trouvé')),
        );
        // Rediriger vers la page de connexion
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } else {
      debugPrint('Aucun utilisateur connecté dans SharedPreferences');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun utilisateur connecté')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
    await AuthService.debugSharedPreferences();
  }
  Future<void> _resetScores() async {
    if (_username != null) {
      await AuthService.resetScores(_username!);
      setState(() {
        _scores = {};
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scores réinitialisés')),
      );
    }
  }

  Future<void> _refreshScores() async {
    await _loadScores();
  }


  @override
  Widget build(BuildContext context) {
    debugPrint('Construction de ScoresPage avec scores : $_scores');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshScores,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Meilleurs Scores',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _scores.isEmpty
                    ? const Center(child: Text('Aucun score enregistré'))
                    : ListView.builder(
                  itemCount: _scores.length,
                  itemBuilder: (context, index) {
                    final key = _scores.keys.elementAt(index);
                    final score = _scores[key];
                    // Nettoyer la clé pour l'affichage
                    final cleanKey = key.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
                    final parts = cleanKey.split('_');
                    final category = parts.length > 1 ? parts[0] : cleanKey;
                    final difficulty = parts.length > 1 ? parts[1] : 'inconnu';
                    debugPrint('Affichage du score : key=$key, cleanKey=$cleanKey, category=$category, difficulty=$difficulty, score=$score');
                    return Card(
                      child: ListTile(
                        title: Text('$category (${difficulty.capitalize()})'),
                        trailing: Text(
                          '${(score! * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: _resetScores,
                icon: const Icon(Icons.delete),
                label: const Text('Réinitialiser Scores'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
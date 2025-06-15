import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quizinteractif/pages/quiz.page.dart';
import 'package:quizinteractif/services/auth.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int total;
  final List<Map<String, dynamic>> questions;
  final List<String?> userAnswers;
  final String category;
  final String difficulty;
  final Function(ThemeMode) onThemeChanged;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.questions,
    required this.userAnswers,
    required this.category,
    required this.difficulty,
    required this.onThemeChanged,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
    // Appeler _saveScore une seule fois lors de l'initialisation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveScore(context);
    });
  }

  Future<void> _saveScore(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUser');
    if (username != null) {
      try {
        final scorePercentage = widget.score / widget.total;
        await AuthService.saveScore(
          username,
          widget.category,
          widget.difficulty,
          scorePercentage,
        );
        debugPrint('Score sauvegardé pour $username : $scorePercentage');
      } catch (e) {
        debugPrint('Erreur lors de l\'enregistrement du score : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement du score : $e')),
        );
      }
    } else {
      debugPrint('Aucun utilisateur connecté pour sauvegarder le score');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucun utilisateur connecté')),
      );
    }
  }

  Future<bool> _checkIfConnected() async {
    final isConnected = await AuthService.isUserConnected();
    final username = await AuthService.getCurrentUser();
    return isConnected && username != null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double percentage = (widget.score / widget.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎉 Résultats du Quiz"),
        backgroundColor: const Color(0xFF6C5CE7),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            colors: [Colors.black87, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Score principal
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: isDark ? Colors.grey.shade800 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      const Text(
                        'Votre score final',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: CircularProgressIndicator(
                              value: percentage,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF6C5CE7)),
                            ),
                          ),
                          Text(
                            '${(percentage * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.score} bonnes réponses sur ${widget.total}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Liste des questions
              Expanded(
                child: ListView.builder(
                  itemCount: widget.questions.length,
                  itemBuilder: (context, index) {
                    final question = widget.questions[index];
                    final correct = question['correct_answer'];
                    final userAnswer = widget.userAnswers[index];
                    final isCorrect = userAnswer == correct;

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question['question'],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Votre réponse : ${userAnswer ?? "Aucune"}',
                                  style: TextStyle(
                                    color: isCorrect ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            if (!isCorrect)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Bonne réponse : $correct',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Boutons d’action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final isConnected = await _checkIfConnected();
                      if (isConnected) {
                        Navigator.pushReplacementNamed(context, '/accueil');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez vous connecter')),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    icon: const Icon(Icons.home),
                    label: const Text("Accueil"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final isConnected = await _checkIfConnected();
                      if (isConnected) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => QuizPage(
                              questions: widget.questions,
                              category: widget.category,
                              difficulty: widget.difficulty,
                              onThemeChanged: widget.onThemeChanged,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez vous connecter')),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text("Rejouer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Thème switch
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple.shade100),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Thème'),
                    CupertinoSwitch(
                      value: isDark,
                      onChanged: (value) {
                        widget.onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(value
                                ? 'Thème sombre activé'
                                : 'Thème clair activé'),
                            backgroundColor: const Color(0xFF6C5CE7),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      activeColor: const Color(0xFF6C5CE7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
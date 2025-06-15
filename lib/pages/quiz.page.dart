import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quizinteractif/main.dart';
import 'package:quizinteractif/pages/accueil.page.dart';
import 'package:quizinteractif/pages/resultat.page.dart';
import 'package:quizinteractif/services/auth.service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Ajouter l'alias

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String category;
  final String difficulty;
  final Function(ThemeMode) onThemeChanged;

  const QuizPage({
    super.key,
    required this.questions,
    required this.category,
    required this.difficulty,
    required this.onThemeChanged,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;
  Timer? _timer;        //Déclaration time
  int _timeLeft = 15;
  List<String> _shuffledAnswers = [];
  final List<String?> _userAnswers = [];
  static const _primaryColor = Color(0xFF6C5CE7); // Violet moderne
  static const _secondaryColor = Color(0xFF00CEFF); // Bleu clair
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _shuffleAnswers();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        _handleTimeout();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    _showAnswer(null);
  }

  void _showAnswer(String? answer) {
    setState(() {
      _selectedAnswer = answer;
      _answered = true;

      if (answer == _currentQuestion()['correct_answer']) {
        _score++;
      }
      _userAnswers.add(answer);

      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    });
  }

  void _nextQuestion() {
    _timer?.cancel();

    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answered = false;
        _shuffleAnswers();
      });
      _startTimer();
    } else {
      _showResult();
    }
  }
  void _showResult() async {
    final scorePercentage = _score / widget.questions.length;
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final username = await AuthService.getCurrentUser();

    debugPrint('showResult: firebaseUser=${firebaseUser?.email}, username=$username');

    if (firebaseUser == null || username == null) {
      debugPrint('Aucun utilisateur connecté : FirebaseUser=$firebaseUser, SharedPreferences username=$username');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucun utilisateur connecté')),
      );
      return;
    }

    try {
      final user = await AuthService.getUser(username);
      if (user == null) {
        debugPrint('Utilisateur $username non trouvé dans SharedPreferences');
        await AuthService.registerUser(username); // Réenregistrer l'utilisateur si nécessaire
      }

      await AuthService.saveScore(
        username,
        widget.category,
        widget.difficulty,
        scorePercentage,
      );
      debugPrint('Score sauvegardé : ${widget.category}, ${widget.difficulty}, $scorePercentage');
      await AuthService.debugSharedPreferences();
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement du score : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement du score : $e')),
      );
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultPage(
          score: _score,
          total: widget.questions.length,
          questions: widget.questions,
          userAnswers: _userAnswers,
          category: widget.category,
          difficulty: widget.difficulty,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    widget.onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
  }

  Map<String, dynamic> _currentQuestion() => widget.questions[_currentQuestionIndex];

  void _shuffleAnswers() {
    final question = _currentQuestion();
    _shuffledAnswers = [
      ...List<String>.from(question['incorrect_answers']),
      question['correct_answer'],
    ];
    _shuffledAnswers.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final question = _currentQuestion();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Score: $_score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: _isDarkMode
              ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Timer et barre de progression
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _timeLeft / 15,
                    backgroundColor: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _timeLeft > 5 ? _primaryColor : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_timeLeft secondes restantes',
                    style: TextStyle(
                      color: _timeLeft > 5
                          ? (_isDarkMode ? Colors.white : Colors.black)
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Carte de question
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Catégorie et difficulté
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text(
                                      widget.category,
                                      style: TextStyle(
                                        color: _isDarkMode ? Colors.white : _primaryColor,
                                      ),
                                    ),
                                    backgroundColor: _isDarkMode
                                        ? _primaryColor.withOpacity(0.3)
                                        : _primaryColor.withOpacity(0.1),
                                  ),
                                  Chip(
                                    label: Text(
                                      widget.difficulty.capitalize(),
                                      style: TextStyle(
                                        color: _isDarkMode ? Colors.white : _secondaryColor,
                                      ),
                                    ),
                                    backgroundColor: _isDarkMode
                                        ? _secondaryColor.withOpacity(0.3)
                                        : _secondaryColor.withOpacity(0.1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Question
                              Text(
                                question['question'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _isDarkMode ? Colors.white : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Réponses
                      ..._shuffledAnswers.map((answer) =>
                          _buildAnswerButton(answer)).toList(),
                    ],
                  ),
                ),
              ),

              // Bas de page
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Thème
                    Row(
                      children: [
                        Icon(
                          _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                          color: _isDarkMode ? _secondaryColor : Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thème ${_isDarkMode ? "Sombre" : "Clair"}',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            value: _isDarkMode,
                            onChanged: _toggleTheme,
                            activeColor: _primaryColor,
                          ),
                        ),
                      ],
                    ),

                    // Progression
                    Text(
                      '${_currentQuestionIndex + 1}/${widget.questions.length}',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildAnswerButton(String answer) {
    final isCorrect = answer == _currentQuestion()['correct_answer'];
    final isSelected = answer == _selectedAnswer;
    final bool showCorrect = _answered && isCorrect;

    Color backgroundColor = _isDarkMode ? Colors.grey.shade700 : Colors.white;
    Color borderColor = _isDarkMode ? Colors.grey.shade600 : _primaryColor.withOpacity(0.3);
    Color textColor = _isDarkMode ? Colors.white : Colors.black87;
    IconData? icon;
    Color? iconColor;

    if (_answered) {
      if (isCorrect && isSelected) {
        backgroundColor = Colors.green.shade600;
        borderColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check;
        iconColor = Colors.white;
      } else if (!isCorrect && isSelected) {
        backgroundColor = Colors.red.shade600;
        borderColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.close;
        iconColor = Colors.white;
      } else if (showCorrect) {
        backgroundColor = Colors.green.shade100.withOpacity(_isDarkMode ? 0.3 : 1);
        borderColor = Colors.green;
        textColor = _isDarkMode ? Colors.white : Colors.black;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: _answered ? null : () => _showAnswer(answer),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, color: iconColor, size: 20),
            if (icon != null)
              const SizedBox(width: 12),
            Expanded(
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
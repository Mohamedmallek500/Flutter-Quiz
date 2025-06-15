import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizinteractif/menu/drawer.widget.dart';
import 'package:quizinteractif/pages/quiz.page.dart';
import 'package:quizinteractif/services/auth.service.dart';

class AccueilPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged; // Elle prend une fonction en paramètre : onThemeChanged, pour changer entre mode clair et mode sombre.

  const AccueilPage({super.key, required this.onThemeChanged});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  static const _appTitle = 'Quiz Interactif';
  static const _apiCategoriesUrl = 'https://opentdb.com/api_category.php';
  static const _primaryColor = Color(0xFF6C5CE7); // Violet moderne
  static const _secondaryColor = Color(0xFF00CEFF); // Bleu clair
  static const _minQuestions = 5;
  static const _maxQuestions = 50;
  static const _defaultQuestions = 5;

  List<dynamic> _categories = [];   // contient la liste des catégories de quiz récupérées de l'API
  String? _selectedCategory;
  String _selectedDifficulty = 'easy';
  int _numberOfQuestions = _defaultQuestions;
  bool _isLoading = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(_apiCategoriesUrl));  //Elle utilise http.get pour envoyer une requête GET à l’API
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = data['trivia_categories'];
          _isLoading = false;
        });
      } else {
        _showErrorSnackbar('Erreur lors du chargement des catégories');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur de connexion');
    } finally {
      if (_isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleTheme(bool value) {   //Inverse le thème clair/sombre et appelle widget.onThemeChanged(...)
    setState(() {
      _isDarkMode = value;
    });
    widget.onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
    _showThemeSnackbar(value ? 'Thème sombre activé' : 'Thème clair activé');
  }

  void _showThemeSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'À propos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Quiz Interactif v1.0.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Application développée avec Flutter.\n'
                    'Questions fournies par l\'API Open Trivia Database (OpenTDB).',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(
                    'Fermer',
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: MyDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isDarkMode
                ? [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ]
                : [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isPortrait ? 20 : 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 30),
                    _buildThemeSection(),
                    const SizedBox(height: 30),
                    _buildCategorySection(),
                    const SizedBox(height: 25),
                    _buildDifficultySection(),
                    const SizedBox(height: 25),
                    _buildQuestionsCountSection(),
                    const SizedBox(height: 40),
                    _buildStartButton(),
                    const SizedBox(height: 20),
                    _buildAboutButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {  //Barre en haut avec titre centré et style personnalisé
    return AppBar(
      title: const Text(
        _appTitle,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      backgroundColor: _primaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Text(
              'Bienvenue dans Quiz Interactif !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'Configurez votre quiz préféré en sélectionnant les options ci-dessous',
              style: TextStyle(
                fontSize: 16,
                color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Icon(
              Icons.quiz_outlined,
              size: 50,
              color: _secondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection() {  //Contient un CupertinoSwitch pour activer/désactiver le thème sombre.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Apparence'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                      color: _isDarkMode ? _secondaryColor : Colors.amber,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Mode ${_isDarkMode ? "Sombre" : "Clair"}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                Transform.scale(
                  scale: 1.2,
                  child: CupertinoSwitch(
                    value: _isDarkMode,
                    onChanged: _toggleTheme,
                    activeColor: _primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Catégorie'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              hint: Text(
                'Sélectionnez une catégorie',
                style: TextStyle(
                  color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'].toString(),
                  child: Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(15),
              dropdownColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySection() {  //choix de la difficulté
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Difficulté'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedDifficulty,
              items: ['easy', 'medium', 'hard'].map((difficulty) {
                return DropdownMenuItem<String>(
                  value: difficulty,
                  child: Text(
                    difficulty.capitalize(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDifficulty = value!);
              },
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(15),
              dropdownColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsCountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Nombre de questions'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                Text(
                  '$_numberOfQuestions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Slider(
                  value: _numberOfQuestions.toDouble(),
                  min: _minQuestions.toDouble(),
                  max: _maxQuestions.toDouble(),
                  divisions: _maxQuestions - _minQuestions,
                  activeColor: _primaryColor,
                  inactiveColor: _primaryColor.withOpacity(0.3),
                  thumbColor: Colors.white,
                  label: _numberOfQuestions.toString(),
                  onChanged: (value) {
                    setState(() => _numberOfQuestions = value.toInt());
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Min: $_minQuestions',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Max: $_maxQuestions',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: _selectedCategory == null ? null : _startQuiz,
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Commencer le Quiz'),
          SizedBox(width: 10),
          Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    );
  }

  Widget _buildAboutButton() {
    return TextButton(
      onPressed: _showAboutDialog,
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
      child: const Text('À propos'),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _isDarkMode ? Colors.grey.shade400 : _primaryColor.withOpacity(0.8),
        ),
      ),
    );
  }

  void _startQuiz() async {
    final url = Uri.parse(
      'https://opentdb.com/api.php?amount=$_numberOfQuestions&category=$_selectedCategory&difficulty=$_selectedDifficulty&type=multiple',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final questions = List<Map<String, dynamic>>.from(data['results']);

        if (questions.isEmpty) {
          _showErrorSnackbar("Aucune question disponible pour ces paramètres.");
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizPage(
              questions: questions,
              category: _categories.firstWhere((cat) => cat['id'].toString() == _selectedCategory)['name'],
              difficulty: _selectedDifficulty,
              onThemeChanged: widget.onThemeChanged,
            ),
          ),
        );
      } else {
        _showErrorSnackbar("Erreur lors du chargement des questions.");
      }
    } catch (e) {
      _showErrorSnackbar("Erreur de connexion ou réponse invalide.");
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
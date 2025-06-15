import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:quizinteractif/pages/accueil.page.dart';
import 'package:quizinteractif/pages/inscription.page.dart';
import 'package:quizinteractif/pages/login.page.dart';
import 'package:quizinteractif/pages/scores.page.dart';
import 'package:quizinteractif/services/auth.service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    AuthService.debugSharedPreferences(); // Pour debug
  }

  // Charger le thème depuis SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'system';
    setState(() {
      _themeMode = switch (themeString) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    });
  }

  // Enregistrer le thème
  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString('themeMode', themeString);
    setState(() => _themeMode = mode);
  }

  // Définir les routes
  Map<String, WidgetBuilder> get routes => {
    '/accueil': (_) => AccueilPage(onThemeChanged: _saveTheme),
    '/login': (_) => LoginPage(),
    '/inscription': (_) => InscriptionPage(onThemeChanged: _saveTheme),
    '/scores': (_) => const ScoresPage(),
  };

  // Thème clair
  final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
      headlineSmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    ),
    dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 1),
  );

  // Thème sombre
  final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.grey[850],
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white60),
      headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 1),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            bool c = snapshot.data?.getBool('connect') ?? false; // Changé de 'connected' à 'connect'
            if (c) return AccueilPage(onThemeChanged: _saveTheme);
          }
          return LoginPage(); // Changé de InscriptionPage à LoginPage
        },
      ),
    );
  }
}
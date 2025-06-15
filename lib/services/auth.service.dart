import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Ajouter l'alias
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizinteractif/models/user.model.dart';

class AuthService {
  static const String _usersKey = 'users';

  // Get a user by username
  static Future<User?> getUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(username);
    debugPrint('Tentative de récupération pour username=$username');
    debugPrint('Clé recherchée : $username, Données brutes : $userJson');
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson);
        if (userMap is Map<String, dynamic>) {
          final user = User.fromMap(userMap);
          debugPrint('Utilisateur décodé : ${user.username}, scores : ${user.scores}');
          return user;
        } else {
          debugPrint('Erreur : Données JSON invalides pour $username, JSON : $userJson');
          return null;
        }
      } catch (e) {
        debugPrint('Erreur lors du décodage de l\'utilisateur $username : $e');
        return null;
      }
    }
    debugPrint('Aucune donnée trouvée pour l\'utilisateur : $username');
    return null;
  }
  // Save a new user
  static Future<void> registerUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final existingUser = await getUser(username);
    if (existingUser != null) {
      debugPrint('Utilisateur $username existe déjà dans SharedPreferences');
      return;
    }

    final user = User(username: username, scores: {});
    final userJson = jsonEncode(user.toMap());
    debugPrint('Tentative d\'enregistrement de l\'utilisateur : $username, JSON : $userJson');
    final success = await prefs.setString(username, userJson);
    if (!success) {
      debugPrint('Échec de l\'enregistrement de l\'utilisateur : $username');
      throw Exception('Échec de l\'enregistrement de l\'utilisateur');
    }

    final usersList = prefs.getStringList(_usersKey) ?? [];
    if (!usersList.contains(username)) {
      usersList.add(username);
      final listSuccess = await prefs.setStringList(_usersKey, usersList);
      if (!listSuccess) {
        debugPrint('Échec de la mise à jour de la liste des utilisateurs');
        throw Exception('Échec de la mise à jour de la liste des utilisateurs');
      }
      debugPrint('Liste des utilisateurs mise à jour : $usersList');
    }
    debugPrint('Utilisateur $username enregistré avec succès');
    await prefs.setString('currentUser', username);
    await prefs.setBool('connect', true);
    await debugSharedPreferences();

    // Vérifier que les données sont bien persistées
    final savedUserJson = prefs.getString(username);
    if (savedUserJson != userJson) {
      debugPrint('Erreur : Les données enregistrées pour $username ne correspondent pas');
      throw Exception('Échec de la vérification des données utilisateur');
    }
  }
  static Future<bool> isUserConnected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('connect') ?? false;
  }

  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentUser');
  }

  static Future<bool> authenticateUser(String email, String password) async {
    try {
      await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('connect', true);
      await prefs.setString('currentUser', email);
      await registerUser(email); // Ajouter l'utilisateur à SharedPreferences s'il n'existe pas
      await debugSharedPreferences();
      debugPrint('Connexion réussie pour $email');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Erreur Firebase lors de l\'authentification : ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Erreur générale lors de l\'authentification : $e');
      return false;
    }
  }
  static Future<void> saveScore(String username, String category, String difficulty, double score) async {
    final prefs = await SharedPreferences.getInstance();
    final user = await getUser(username);
    if (user != null) {
      // Normaliser la catégorie et la difficulté
      final cleanCategory = category.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final cleanDifficulty = difficulty.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final scoreKey = '${cleanCategory}_${cleanDifficulty}';
      debugPrint('Enregistrement du score pour $username : category=$category, cleanCategory=$cleanCategory, difficulty=$difficulty, cleanDifficulty=$cleanDifficulty, scoreKey=$scoreKey, score=$score');

      // Mettre à jour le score
      user.scores[scoreKey] = score;
      final userJson = jsonEncode(user.toMap());
      debugPrint('JSON à enregistrer : $userJson');

      // Enregistrer les données
      final success = await prefs.setString(username, userJson);
      if (success) {
        // Vérifier immédiatement après l'enregistrement
        final savedUserJson = prefs.getString(username);
        if (savedUserJson == userJson) {
          debugPrint('Score enregistré avec succès pour $username : $scoreKey = $score');
        } else {
          debugPrint('Erreur : Les données enregistrées ne correspondent pas. Attendu : $userJson, Trouvé : $savedUserJson');
          throw Exception('Échec de la vérification des données après enregistrement');
        }
      } else {
        debugPrint('Échec de l\'enregistrement du score pour $username');
        throw Exception('Échec de l\'enregistrement du score');
      }

      // Débogage pour confirmer l'état
      await debugSharedPreferences();
    } else {
      debugPrint('Impossible d\'enregistrer le score : utilisateur $username non trouvé');
      throw Exception('Utilisateur non trouvé');
    }
  }
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = prefs.getStringList(_usersKey) ?? [];
    debugPrint('Liste des utilisateurs récupérée : $usersList');
    final users = <User>[];
    for (var username in usersList) {
      final user = await getUser(username);
      if (user != null) {
        users.add(user);
      } else {
        debugPrint('Données manquantes pour l\'utilisateur : $username');
      }
    }
    debugPrint('Utilisateurs chargés : ${users.map((u) => u.username).toList()}');
    return users;
  }

  static Future<void> updateUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setString(updatedUser.username, jsonEncode(updatedUser.toMap()));
    if (success) {
      debugPrint('Utilisateur mis à jour : ${updatedUser.username}');
    } else {
      debugPrint('Échec de la mise à jour de l\'utilisateur : ${updatedUser.username}');
      throw Exception('Échec de la mise à jour de l\'utilisateur');
    }
  }

  static Future<void> resetScores(String username) async {
    final user = await getUser(username);
    if (user != null) {
      user.scores.clear();
      await updateUser(user);
      debugPrint('Scores réinitialisés pour : $username');
    } else {
      debugPrint('Impossible de réinitialiser les scores : utilisateur $username non trouvé');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUser');
    await prefs.setBool('connect', false);
    await prefs.remove('currentUser');
    debugPrint('Déconnexion réussie : connect=false, currentUser supprimé');
    if (username != null) {
      final userJson = prefs.getString(username);
      debugPrint('Vérification après déconnexion : Données utilisateur pour $username : $userJson');
      if (userJson == null) {
        debugPrint('Erreur : Les données de l\'utilisateur $username ont été supprimées');
      }
    }
    await debugSharedPreferences();
  }
  static Future<void> debugSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    debugPrint('Clés actuellement en mémoire (après enregistrement du score) : $allKeys');
    debugPrint('=== Début du débogage SharedPreferences ===');
    debugPrint('Clés présentes : $allKeys');
    for (var key in allKeys) {
      final value = prefs.get(key);
      debugPrint('Clé: $key | Valeur: $value');
    }
    debugPrint('=== Fin du débogage SharedPreferences ===');
  }
}
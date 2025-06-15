# 📱 Flutter Quiz Interactif

Une application mobile Flutter interactive permettant aux utilisateurs de jouer à un quiz sur différentes catégories de sujets. Les questions sont récupérées en temps réel à partir de l'API Open Trivia Database (OpenTDB).

---

## 🧠 Présentation du projet

Ce projet a pour objectif de créer une application Flutter ludique, éducative et personnalisable.  
L'utilisateur peut choisir :
- Une catégorie de questions (Science, Histoire, Divertissement, etc.)
- Un niveau de difficulté (Facile, Moyen, Difficile)
- Le nombre de questions à répondre (5, 10, 15, etc.)

L'application affiche ensuite les questions une par une avec des réponses à choix multiple. Un système de score est intégré et un retour est fourni à la fin du quiz.

---

## 🌐 API utilisée

- **Open Trivia Database (OpenTDB)**  
  Site officiel : [https://opentdb.com/api_config.php](https://opentdb.com/api_config.php)  
  Cette API gratuite fournit des questions de quiz dans diverses catégories et niveaux.

---

## 📲 Fonctionnalités principales

### 🏠 Écran d'accueil
- Menu principal avec les options :
  - **Commencer un quiz**
  - **À propos de l'application**

### ⚙️ Paramètres du quiz
- **Choix de la catégorie** : récupérées dynamiquement via OpenTDB
- **Niveau de difficulté** : Facile / Moyen / Difficile
- **Nombre de questions** : 5, 10, 15, etc.

### ❓ Écran de quiz
- Affichage d'une question à la fois
- Réponses à choix multiple
- Chronomètre pour chaque question
- Retour visuel immédiat (✅ Bonne réponse, ❌ Mauvaise réponse)
- Passage automatique à la question suivante

### 🏁 Résultats
- Affichage du score final
- Affichage des réponses correctes et incorrectes
- Option pour rejouer ou revenir à l'accueil

---

## 🛠️ Technologies utilisées

- **Flutter** (Dart)
- Intégration HTTP (package `http`)
- Gestion d'état simple (ex : `setState`)
- Design responsive et animations Flutter

---

## 🧪 À faire / améliorations futures

- Authentification utilisateur (Firebase)
- Sauvegarde de scores
- Tableau de classement
- Mode multijoueur en ligne
- Localisation (support multilingue)

---

## 🔗 Liens utiles

- API OpenTDB : [https://opentdb.com/api_config.php](https://opentdb.com/api_config.php)
- Flutter : [https://flutter.dev](https://flutter.dev)

---

## 👨‍💻 Auteur

- Mohamed Mallek  
  [GitHub](https://github.com/Mohamedmallek500)

---

## 📄 Licence

Ce projet est open-source et disponible sous la licence MIT.

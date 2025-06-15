class User {
  final String username;
  final Map<String, double> scores;  //contenant les scores de l’utilisateur pour différents quiz

  User({required this.username, required this.scores});

  Map<String, dynamic> toMap() {  //utile pour l’enregistrement dans une base de données ou dans des fichiers JSON
    return {
      'username': username,
      'scores': scores,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {  //utile lors de la récupération des données
    return User(
      username: map['username'] as String,
      scores: Map<String, double>.from(map['scores'] ?? {}),
    );
  }
}

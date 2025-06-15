import 'package:flutter/material.dart';
import 'package:quizinteractif/services/auth.service.dart';

Widget _buildDrawerTile(
    BuildContext context,
    IconData icon,
    String title,
    String routeName,
    ) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName);
      },
    ),
  );
}

Widget _buildLogoutTile(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.logout, color: Colors.red),
      ),
      title: const Text(
        'Déconnexion',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () async {
        await AuthService.logout();
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      },
    ),
  );
}

Drawer MyDrawer(BuildContext context) {
  return Drawer(
    width: MediaQuery.of(context).size.width * 0.75,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
    ),
    child: Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.quiz,
                    size: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Quiz App Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: ListView(
                children: [
                  _buildDrawerTile(context, Icons.home, "Accueil", "/accueil"),
                  _buildDrawerTile(context, Icons.quiz, "Commencer un Quiz", "/quiz"),
                  _buildDrawerTile(context, Icons.info, "À Propos", "/about"),
                  _buildDrawerTile(context, Icons.leaderboard, "Classement", "/scores"),
                  _buildDrawerTile(context, Icons.settings, "Paramètres", "/settings"),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  _buildLogoutTile(context),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
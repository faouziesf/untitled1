// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:untitled1/screens/club_list_screen.dart';
import 'package:untitled1/screens/joueur_list_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil - Gestion Championnat'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu Principal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.group_work), // Icône pour les clubs
              title: Text('Gestion des Clubs'),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClubListScreen()), // Navigue vers la liste des clubs
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person), // Icône pour les joueurs
              title: Text('Gestion des Joueurs'),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoueurListScreen()), // Navigue vers la liste des joueurs
                );
              },
            ),
            // Ajoutez d'autres éléments de menu si nécessaire
          ],
        ),
      ),
      body: Center(
        child: Text('Bienvenue dans votre application de gestion de championnat!'),
      ),
    );
  }
}
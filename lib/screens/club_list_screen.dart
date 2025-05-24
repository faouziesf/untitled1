// lib/screens/club_list_screen.dart
import 'package:flutter/material.dart';
import 'package:untitled1/models/club.dart';
import 'package:untitled1/utils/database_helper.dart';
import 'package:untitled1/screens/add_edit_club_screen.dart';

class ClubListScreen extends StatefulWidget {
  @override
  _ClubListScreenState createState() => _ClubListScreenState();
}

class _ClubListScreenState extends State<ClubListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Club> _clubs = [];

  @override
  void initState() {
    super.initState();
    _refreshClubList();
  }

  Future<void> _refreshClubList() async {
    final data = await _dbHelper.getAllClubs();
    setState(() {
      _clubs = data.map((item) => Club.fromMap(item)).toList();
    });
  }

  void _navigateToAddEditClubScreen([Club? club]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditClubScreen(club: club)),
    );
    if (result == true) { // Si un club a été ajouté/modifié
      _refreshClubList();
    }
  }

  Future<void> _deleteClub(int id) async {
    // Afficher une boîte de dialogue de confirmation
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce club ? Cela pourrait affecter les joueurs associés.'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _dbHelper.deleteClub(id);
      _refreshClubList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Club supprimé avec succès')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Clubs'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToAddEditClubScreen(),
          ),
        ],
      ),
      body: _clubs.isEmpty
          ? Center(child: Text('Aucun club. Appuyez sur + pour en ajouter un.'))
          : ListView.builder(
        itemCount: _clubs.length,
        itemBuilder: (context, index) {
          final club = _clubs[index];
          return ListTile(
            title: Text(club.libelle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _navigateToAddEditClubScreen(club),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteClub(club.id!),
                ),
              ],
            ),
            // Optionnel: onTap pour voir les détails du club ou les joueurs du club
          );
        },
      ),
    );
  }
}
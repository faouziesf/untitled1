// lib/screens/joueur_list_screen.dart
import 'package:flutter/material.dart';
import 'package:untitled1/models/joueur.dart';
import 'package:untitled1/models/club.dart' ;
import 'package:untitled1/utils/database_helper.dart';
import 'package:untitled1/screens/add_edit_joueur_screen.dart';
import 'package:url_launcher/url_launcher.dart';


class JoueurListScreen extends StatefulWidget {
  final int? clubId; // Optionnel: pour filtrer les joueurs par club
  final String? clubName; // Optionnel: pour afficher le nom du club dans l'AppBar

  JoueurListScreen({this.clubId, this.clubName});

  @override
  _JoueurListScreenState createState() => _JoueurListScreenState();
}

class _JoueurListScreenState extends State<JoueurListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Joueur> _joueurs = [];
  Map<int, String> _clubNames = {}; // Pour stocker les noms des clubs
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClubNamesAndRefreshList();
  }

  Future<void> _loadClubNamesAndRefreshList() async {
    final clubsData = await _dbHelper.getAllClubs();
    setState(() {
      _clubNames = { for (var club in clubsData) club['id'] as int : club['libelle'] as String };
    });
    _refreshJoueurList();
  }

  Future<void> _refreshJoueurList() async {
    List<Map<String, dynamic>> data;
    if (_searchQuery.isNotEmpty) {
      data = await _dbHelper.searchJoueur(_searchQuery);
    } else if (widget.clubId != null) {
      data = await _dbHelper.getJoueursByClub(widget.clubId!);
    } else {
      data = await _dbHelper.getAllJoueurs();
    }
    setState(() {
      _joueurs = data.map((item) => Joueur.fromMap(item)).toList();
    });
  }

  void _navigateToAddEditJoueurScreen([Joueur? joueur]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditJoueurScreen(joueur: joueur, currentClubId: widget.clubId)),
    );
    if (result == true) {
      _loadClubNamesAndRefreshList(); // Rafraîchir après ajout/modif
    }
  }

  Future<void> _deleteJoueur(int id) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce joueur ?'),
          actions: <Widget>[
            TextButton(child: Text('Annuler'), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(child: Text('Supprimer', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.of(context).pop(true)),
          ],
        );
      },
    );
    if (confirmDelete == true) {
      await _dbHelper.deleteJoueur(id);
      _refreshJoueurList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joueur supprimé avec succès')),
      );
    }
  }

  void _callJoueur(String? tel) async {
    if (tel != null && tel.isNotEmpty) {
      final Uri launchUri = Uri(scheme: 'tel', path: tel);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de lancer l\'appel vers $tel')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Numéro de téléphone non disponible')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = 'Liste des Joueurs';
    if (widget.clubName != null) {
      appBarTitle = 'Joueurs du Club: ${widget.clubName}';
    } else if (_searchQuery.isNotEmpty) {
      appBarTitle = 'Résultats de recherche';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          // Affiche le bouton d'ajout seulement si on n'est pas en mode recherche globale (ou affinez la logique)
          if(_searchQuery.isEmpty)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _navigateToAddEditJoueurScreen(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche (visible uniquement si on n'affiche pas les joueurs d'un club spécifique)
          if (widget.clubId == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Rechercher par nom, prénom, téléphone...',
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _refreshJoueurList(); // Rafraîchir la liste à chaque changement
                },
              ),
            ),
          Expanded(
            child: _joueurs.isEmpty
                ? Center(child: Text(_searchQuery.isNotEmpty ? 'Aucun joueur trouvé.' : 'Aucun joueur. Appuyez sur + pour en ajouter un.'))
                : ListView.builder(
              itemCount: _joueurs.length,
              itemBuilder: (context, index) {
                final joueur = _joueurs[index];
                final clubName = joueur.clubId != null ? (_clubNames[joueur.clubId] ?? 'Club inconnu') : 'Sans club';
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text('${joueur.prenom} ${joueur.nom}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Club: $clubName'),
                        if (joueur.tel != null && joueur.tel!.isNotEmpty)
                          Text('Tél: ${joueur.tel}'),
                        if (joueur.dateNaiss != null && joueur.dateNaiss!.isNotEmpty)
                          Text('Né(e) le: ${joueur.dateNaiss}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (joueur.tel != null && joueur.tel!.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.phone, color: Colors.green),
                            onPressed: () => _callJoueur(joueur.tel),
                            tooltip: 'Appeler ${joueur.prenom}',
                          ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _navigateToAddEditJoueurScreen(joueur),
                          tooltip: 'Modifier ${joueur.prenom}',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteJoueur(joueur.id!),
                          tooltip: 'Supprimer ${joueur.prenom}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
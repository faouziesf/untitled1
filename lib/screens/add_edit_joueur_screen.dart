// lib/screens/add_edit_joueur_screen.dart
import 'package:flutter/material.dart';
import 'package:untitled1/models/joueur.dart';
import 'package:untitled1/models/club.dart';
import 'package:untitled1/utils/database_helper.dart';
// import 'package:intl/intl.dart'; // Pour formater les dates si vous utilisez DateTime

class AddEditJoueurScreen extends StatefulWidget {
  final Joueur? joueur;
  final int? currentClubId; // Pour pré-sélectionner le club si on ajoute depuis la liste d'un club

  AddEditJoueurScreen({this.joueur, this.currentClubId});

  @override
  _AddEditJoueurScreenState createState() => _AddEditJoueurScreenState();
}

class _AddEditJoueurScreenState extends State<AddEditJoueurScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late String _nom;
  late String _prenom;
  String? _dateNaiss; // Gardé comme String pour simplicité, ou utiliser DateTime et un DatePicker
  String? _tel;
  int? _selectedClubId;

  bool _isEditing = false;
  List<Club> _clubs = [];
  // TextEditingController pour la date si vous utilisez un DatePicker
  final TextEditingController _dateController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadClubs();
    if (widget.joueur != null) {
      _isEditing = true;
      _nom = widget.joueur!.nom;
      _prenom = widget.joueur!.prenom;
      _dateNaiss = widget.joueur!.dateNaiss;
      _tel = widget.joueur!.tel;
      _selectedClubId = widget.joueur!.clubId;
      if (_dateNaiss != null) _dateController.text = _dateNaiss!;
    } else {
      _nom = '';
      _prenom = '';
      _dateNaiss = null;
      _tel = null;
      _selectedClubId = widget.currentClubId; // Pré-sélection si fournie
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadClubs() async {
    final data = await _dbHelper.getAllClubs();
    setState(() {
      _clubs = data.map((item) => Club.fromMap(item)).toList();
      // Assurez-vous que le clubId sélectionné existe dans la liste des clubs
      if (_selectedClubId != null && !_clubs.any((club) => club.id == _selectedClubId)) {
         // Gérer le cas où le club n'existe plus ou est invalide
         // _selectedClubId = null; // Optionnel: réinitialiser si le club n'est pas trouvé
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateNaiss != null ? DateTime.tryParse(_dateNaiss!) ?? DateTime.now() : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'), // Pour le calendrier en français
    );
    if (picked != null) {
      setState(() {
        // Formatez la date comme vous le souhaitez, par exemple YYYY-MM-DD
        // _dateNaiss = DateFormat('yyyy-MM-dd').format(picked);
        _dateNaiss = "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _dateController.text = _dateNaiss!;
      });
    }
  }

  Future<void> _saveJoueur() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Joueur joueur = Joueur(
        id: widget.joueur?.id,
        nom: _nom,
        prenom: _prenom,
        dateNaiss: _dateNaiss,
        tel: _tel,
        clubId: _selectedClubId,
      );

      if (_isEditing) {
        await _dbHelper.updateJoueur(joueur.toMap());
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joueur modifié avec succès!')),
        );
      } else {
        await _dbHelper.insertJoueur(joueur.toMap());
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joueur ajouté avec succès!')),
        );
      }
      Navigator.pop(context, true); // Retourne true
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier Joueur' : 'Ajouter Joueur'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Utilisez ListView pour éviter les problèmes de débordement avec le clavier
            children: <Widget>[
              TextFormField(
                initialValue: _nom,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un nom' : null,
                onSaved: (value) => _nom = value!,
              ),
              TextFormField(
                initialValue: _prenom,
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un prénom' : null,
                onSaved: (value) => _prenom = value!,
              ),
               TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date de Naissance (YYYY-MM-DD)',
                  hintText: 'Appuyez pour choisir une date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true, // Empêche la saisie manuelle
                onTap: () => _selectDate(context),
                onSaved: (value) => _dateNaiss = value,
                // validator: (value) { // Optionnel : valider le format si la saisie manuelle est autorisée
                //   if (value != null && value.isNotEmpty && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                //     return 'Format de date invalide (YYYY-MM-DD)';
                //   }
                //   return null;
                // },
              ),
              TextFormField(
                initialValue: _tel,
                decoration: InputDecoration(labelText: 'Téléphone (optionnel)'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => _tel = value,
              ),
              SizedBox(height: 10),
              _clubs.isEmpty
              ? Center(child: Text("Chargement des clubs... Créez d'abord des clubs."))
              : DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Club (optionnel)'),
                  value: _selectedClubId,
                  items: [
                    DropdownMenuItem<int>(
                      value: null, // Pour "Aucun club"
                      child: Text('Aucun club / Sans club'),
                    ),
                    ..._clubs.map((club) { // Les "..." est l'opérateur de spread
                      return DropdownMenuItem<int>(
                        value: club.id,
                        child: Text(club.libelle),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedClubId = value;
                    });
                  },
                  // validator: (value) => value == null ? 'Sélectionnez un club' : null, // Si obligatoire
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveJoueur,
                child: Text(_isEditing ? 'Enregistrer les modifications' : 'Ajouter le Joueur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
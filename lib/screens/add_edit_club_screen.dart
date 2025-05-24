// lib/screens/add_edit_club_screen.dart
import 'package:flutter/material.dart';
import 'package:untitled1/models/club.dart';
import 'package:untitled1/utils/database_helper.dart';

class AddEditClubScreen extends StatefulWidget {
  final Club? club; // Nullable, car on peut ajouter un nouveau club

  AddEditClubScreen({this.club});

  @override
  _AddEditClubScreenState createState() => _AddEditClubScreenState();
}

class _AddEditClubScreenState extends State<AddEditClubScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _libelle;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.club != null) {
      _isEditing = true;
      _libelle = widget.club!.libelle;
    } else {
      _libelle = '';
    }
  }

  Future<void> _saveClub() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Club club = Club(id: widget.club?.id, libelle: _libelle);

      if (_isEditing) {
        await _dbHelper.updateClub(club.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Club modifié avec succès!')),
        );
      } else {
        await _dbHelper.insertClub(club.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Club ajouté avec succès!')),
        );
      }
      Navigator.pop(context, true); // Retourne true pour indiquer un changement
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier Club' : 'Ajouter Club'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _libelle,
                decoration: InputDecoration(labelText: 'Nom du Club (Libellé)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom pour le club';
                  }
                  return null;
                },
                onSaved: (value) => _libelle = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveClub,
                child: Text(_isEditing ? 'Enregistrer les modifications' : 'Ajouter le Club'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
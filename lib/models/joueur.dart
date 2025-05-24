class Joueur {
  int? id;
  String nom;
  String prenom;
  String? dateNaiss; // Make nullable or handle default/validation
  String? tel;
  int? clubId; // Foreign key

  Joueur({
    this.id,
    required this.nom,
    required this.prenom,
    this.dateNaiss,
    this.tel,
    this.clubId,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'nom': nom,
      'prenom': prenom,
      'dateNaiss': dateNaiss,
      'tel': tel,
      'clubId': clubId,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Joueur.fromMap(Map<String, dynamic> map) {
    return Joueur(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      dateNaiss: map['dateNaiss'],
      tel: map['tel'],
      clubId: map['clubId'],
    );
  }
}
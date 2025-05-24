class Club {
  int? id; // Nullable if it's a new club not yet saved to DB
  String libelle;

  Club({this.id, required this.libelle});

  // Convert a Club object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'libelle': libelle,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Extract a Club object from a Map object
  factory Club.fromMap(Map<String, dynamic> map) {
    return Club(
      id: map['id'],
      libelle: map['libelle'],
    );
  }
}
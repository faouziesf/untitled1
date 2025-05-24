import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async'; // For Future

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'championnat.db');
    return await openDatabase(
      path,
      version: 1, // Increment this if you change the schema
      onCreate: _onCreate,
    );
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Club (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        libelle TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Joueur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        dateNaiss TEXT, -- Consider storing as TEXT (ISO8601) or INTEGER (timestamp)
        tel TEXT,
        clubId INTEGER,
        FOREIGN KEY (clubId) REFERENCES Club (id) ON DELETE SET NULL -- or ON DELETE CASCADE
      )
    ''');
    print("Database and tables created!");
  }

  // --- Club Table Methods ---

  Future<int> insertClub(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('Club', row);
  }

  Future<List<Map<String, dynamic>>> getAllClubs() async {
    Database db = await database;
    return await db.query('Club');
  }

  Future<int> updateClub(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('Club', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteClub(int id) async {
    Database db = await database;
    return await db.delete('Club', where: 'id = ?', whereArgs: [id]);
  }


  // --- Joueur Table Methods ---

  Future<int> insertJoueur(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('Joueur', row);
  }

  Future<List<Map<String, dynamic>>> getAllJoueurs() async {
    Database db = await database;
    // You might want to join with Club table to get club name
    return await db.query('Joueur');
  }

  Future<List<Map<String, dynamic>>> getJoueursByClub(int clubId) async {
    Database db = await database;
    return await db.query('Joueur', where: 'clubId = ?', whereArgs: [clubId]);
  }

  Future<List<Map<String, dynamic>>> searchJoueur(String query) async {
    Database db = await database;
    // Basic search by nom, prenom, or tel. Adjust as needed.
    return await db.query('Joueur',
        where: 'nom LIKE ? OR prenom LIKE ? OR tel LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%']);
  }

  Future<int> updateJoueur(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('Joueur', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteJoueur(int id) async {
    Database db = await database;
    return await db.delete('Joueur', where: 'id = ?', whereArgs: [id]);
  }

// You can add more specific query methods as needed
}
import 'package:checkpoint_app/kernel/models/face.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<void> init() async {
    final path = join(await getDatabasesPath(), 'faces.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE faces (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            matricule TEXT,
            embedding TEXT,
            image_path TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertFace(FacePicture face) async {
    await _db!.insert('faces', face.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FacePicture>> getAllFaces() async {
    final List<Map<String, dynamic>> maps = await _db!.query('faces');
    if (kDebugMode) {
      print(maps);
    }
    return maps.map(FacePicture.fromMap).toList();
  }

  Future<void> deleteAll() async {
    await _db!.delete('faces');
  }
}

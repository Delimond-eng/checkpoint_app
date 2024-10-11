import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/planning.dart';
import 'http_manager.dart';

class DatabaseHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'schedules.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE schedules(id INTEGER PRIMARY KEY, libelle TEXT, start_time TEXT, end_time TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertSchedule() async {
    try {
      final db = await DatabaseHelper.database();
      var schedules = await HttpManager.getAllPlannings();

      await db.transaction((txn) async {
        for (var schedule in schedules) {
          await txn.insert(
            'schedules',
            schedule.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      print("datas stored !");
    } catch (e) {
      print('Error inserting schedules: $e');
    }
  }

  static Future<List<Planning>> getSchedules() async {
    final db = await DatabaseHelper.database();
    final List<Map<String, dynamic>> maps = await db.query('schedules');
    return List.generate(maps.length, (i) {
      return Planning.fromJson(maps[i]);
    });
  }
}

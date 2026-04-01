import '/kernel/models/user.dart';
import '/kernel/models/announce.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/planning.dart';

class LocalDbService {
  static final LocalDbService instance = LocalDbService._init();
  static Database? _database;

  LocalDbService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('salama_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Passage à la version 4 pour inclure la colonne 'time'
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE announces (
  id INTEGER PRIMARY KEY,
  title TEXT,
  content TEXT,
  created_at TEXT
)
''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE pending_actions ADD COLUMN key TEXT');
      await db.execute('ALTER TABLE pending_actions ADD COLUMN started_at TEXT');
      await db.execute('ALTER TABLE pending_actions ADD COLUMN ended_at TEXT');
      await db.execute('ALTER TABLE pending_actions ADD COLUMN date_reference TEXT');
    }
    if (oldVersion < 4) {
      // Ajout de la colonne 'time' manquante
      await db.execute('ALTER TABLE pending_actions ADD COLUMN time TEXT');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const intType = 'INTEGER';

    await db.execute('''
CREATE TABLE plannings (
  id $intType,
  libelle $textType,
  date $textType,
  start_time $textType,
  end_time $textType,
  site_id $intType,
  site_name $textType
)
''');

    await db.execute('''
CREATE TABLE announces (
  id INTEGER PRIMARY KEY,
  title $textType,
  content $textType,
  created_at $textType
)
''');

    await db.execute('''
CREATE TABLE pending_actions (
  id $idType,
  type $textType, 
  local_session_id $textType,
  patrol_id $textType,
  site_id $intType,
  agency_id $intType,
  agent_id $intType,
  area_id $intType,
  schedule_id $textType,
  matricule $textType,
  comment $textType,
  latlng $textType,
  photo_path $textType,
  created_at $textType,
  key $textType,
  started_at $textType,
  ended_at $textType,
  date_reference $textType,
  time $textType
)
''');
  }

  // --- PLANNINGS ---
  Future<void> savePlannings(List<Planning> plannings) async {
    final db = await instance.database;
    await db.delete('plannings');
    for (var p in plannings) {
      await db.insert('plannings', {
        'id': p.id,
        'libelle': p.libelle,
        'date': p.date,
        'start_time': p.startTime,
        'end_time': p.endTime,
        'site_id': p.siteId,
        'site_name': p.site?.name,
      });
    }
  }

  Future<List<Planning>> getLocalPlannings() async {
    final db = await instance.database;
    final result = await db.query('plannings');
    return result.map((json) => Planning(
      id: json['id'] as int?,
      libelle: json['libelle'] as String?,
      date: json['date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      siteId: json['site_id'] as int?,
      site: Site(name: json['site_name'] as String?),
    )).toList();
  }

  Future<void> deletePlanning(int id) async {
    final db = await instance.database;
    await db.delete('plannings', where: 'id = ?', whereArgs: [id]);
  }

  // --- ANNOUNCES ---
  Future<void> saveAnnounces(List<Announce>? announces) async {
    final db = await instance.database;
    await db.delete('announces');
    for (var a in announces!) {
      await db.insert('announces', {
        'id': a.id,
        'title': a.title,
        'content': a.content,
        'created_at': a.createdAt,
      });
    }
  }

  Future<List<Announce>> getLocalAnnounces() async {
    final db = await instance.database;
    final result = await db.query('announces');
    return result.map((json) => Announce(
      id: json['id'] as int?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      createdAt: json['created_at'] as String?,
    )).toList();
  }

  // --- PENDING ACTIONS ---
  Future<void> addPendingAction(Map<String, dynamic> actionData) async {
    final db = await instance.database;
    await db.insert('pending_actions', actionData);
  }

  Future<List<Map<String, dynamic>>> getPendingActions() async {
    final db = await instance.database;
    return await db.query('pending_actions', orderBy: 'created_at ASC');
  }

  Future<void> updatePendingActionsId(String localSessionId, String realPatrolId) async {
    final db = await instance.database;
    await db.update(
      'pending_actions',
      {'patrol_id': realPatrolId},
      where: 'local_session_id = ? AND (patrol_id IS NULL OR patrol_id = "" OR patrol_id = "0")',
      whereArgs: [localSessionId],
    );
  }

  Future<void> deletePendingAction(int id) async {
    final db = await instance.database;
    await db.delete('pending_actions', where: 'id = ?', whereArgs: [id]);
  }
}

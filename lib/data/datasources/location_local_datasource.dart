import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/location_model.dart';

class LocationLocalDataSource {
  static final LocationLocalDataSource _instance =
      LocationLocalDataSource._internal();

  factory LocationLocalDataSource() => _instance;

  LocationLocalDataSource._internal();

  Database? _database;

  Future<void> initialize() async {
    if (_database != null) return;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, 'location_tracker.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE locations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE preferences(
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS preferences(
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<void> insertLocation(LocationModel location) async {
    await _database!.insert('locations', location.toMap());
  }

  Future<List<LocationModel>> getLocations({int limit = 50}) async {
    final result = await _database!.query(
      'locations',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<void> clearOldLocations(Duration olderThan) async {
    final cutoff = DateTime.now().subtract(olderThan).toIso8601String();
    await _database!.delete(
      'locations',
      where: 'timestamp < ?',
      whereArgs: [cutoff],
    );
  }

  Future<void> saveTrackingState(bool isTracking) async {
    await _database!.insert('preferences', {
      'key': 'is_tracking',
      'value': isTracking ? 'true' : 'false',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> getTrackingState() async {
    final result = await _database!.query(
      'preferences',
      where: 'key = ?',
      whereArgs: ['is_tracking'],
    );
    if (result.isNotEmpty) {
      return result.first['value'] == 'true';
    }
    return false;
  }
}

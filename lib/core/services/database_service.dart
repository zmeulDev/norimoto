import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class DatabaseService {
  static Database? _database;
  static const String dbName = 'car_maintenance.db';
  static const int _currentVersion = 3;

  static Future<void> initialize() async {
    if (_database != null) return;

    try {
      final databasesPath = await getDatabasesPath();
      final dbPath = path.join(databasesPath, dbName);

      debugPrint('Initializing database at: $dbPath');

      _database = await openDatabase(
        dbPath,
        version: _currentVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) async {
          // Debug: Print table names
          final tables = await db
              .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
          debugPrint(
              'Available tables: ${tables.map((t) => t['name']).join(', ')}');
        },
      );

      debugPrint('Database initialized successfully');
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    debugPrint('Creating database tables...');

    try {
      await db.execute('''
        CREATE TABLE vehicles (
          id TEXT PRIMARY KEY NOT NULL,
          make TEXT NOT NULL,
          model TEXT NOT NULL,
          year INTEGER NOT NULL,
          licensePlate TEXT NOT NULL,
          vin TEXT,
          purchaseDate TEXT NOT NULL,
          purchasePrice REAL NOT NULL,
          color TEXT NOT NULL,
          transmission TEXT NOT NULL,
          fuelType TEXT NOT NULL,
          engineSize TEXT,
          enginePower TEXT,
          wheelsSize TEXT,
          wiperSize TEXT,
          lightsCode TEXT,
          notes TEXT NOT NULL DEFAULT ''
        )
      ''');
      debugPrint('Vehicles table created');

      await db.execute('''
        CREATE TABLE service_records (
          id TEXT PRIMARY KEY NOT NULL,
          vehicleId TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          date TEXT NOT NULL,
          reminderDate TEXT,
          cost REAL NOT NULL,
          mileage INTEGER NOT NULL,
          serviceProvider TEXT NOT NULL,
          type TEXT NOT NULL,
          receipts TEXT NOT NULL,
          isScheduled INTEGER NOT NULL DEFAULT 0,
          isRecurring INTEGER NOT NULL DEFAULT 0,
          recurringMonths INTEGER,
          recurringKilometers INTEGER,
          FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
        )
      ''');
      debugPrint('Service records table created');

      await db.execute('''
        CREATE TABLE fuel_records (
          id TEXT PRIMARY KEY NOT NULL,
          vehicleId TEXT NOT NULL,
          date TEXT NOT NULL,
          liters REAL NOT NULL,
          cost REAL NOT NULL,
          odometer INTEGER NOT NULL,
          fullTank INTEGER NOT NULL DEFAULT 1,
          station TEXT,
          notes TEXT,
          FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
        )
      ''');
      debugPrint('Fuel records table created');
    } catch (e) {
      debugPrint('Error creating tables: $e');
      rethrow;
    }
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');

    try {
      if (oldVersion < 2) {
        debugPrint('Upgrading to version 2...');
        // Drop the old service_records table if it exists
        await db.execute('DROP TABLE IF EXISTS service_records');

        // Create the new service_records table with all required fields
        await db.execute('''
          CREATE TABLE service_records (
            id TEXT PRIMARY KEY NOT NULL,
            vehicleId TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            date TEXT NOT NULL,
            reminderDate TEXT,
            cost REAL NOT NULL,
            mileage INTEGER NOT NULL,
            serviceProvider TEXT NOT NULL,
            type TEXT NOT NULL,
            receipts TEXT NOT NULL,
            isScheduled INTEGER NOT NULL DEFAULT 0,
            isRecurring INTEGER NOT NULL DEFAULT 0,
            recurringMonths INTEGER,
            recurringKilometers INTEGER,
            FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
          )
        ''');

        // Add new columns to vehicles table
        await db.execute(
            'ALTER TABLE vehicles ADD COLUMN color TEXT NOT NULL DEFAULT ""');
        await db.execute(
            'ALTER TABLE vehicles ADD COLUMN transmission TEXT NOT NULL DEFAULT "manual"');
        await db.execute(
            'ALTER TABLE vehicles ADD COLUMN fuelType TEXT NOT NULL DEFAULT "petrol"');
        await db.execute('ALTER TABLE vehicles ADD COLUMN engineSize TEXT');
        await db.execute('ALTER TABLE vehicles ADD COLUMN enginePower TEXT');
        await db.execute('ALTER TABLE vehicles ADD COLUMN wheelsSize TEXT');
        await db.execute('ALTER TABLE vehicles ADD COLUMN wiperSize TEXT');
        await db.execute('ALTER TABLE vehicles ADD COLUMN lightsCode TEXT');
        await db.execute(
            'ALTER TABLE vehicles ADD COLUMN notes TEXT NOT NULL DEFAULT ""');
      }

      if (oldVersion < 3) {
        debugPrint('Upgrading to version 3...');
        // Add fuel_records table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS fuel_records (
            id TEXT PRIMARY KEY NOT NULL,
            vehicleId TEXT NOT NULL,
            date TEXT NOT NULL,
            liters REAL NOT NULL,
            cost REAL NOT NULL,
            odometer INTEGER NOT NULL,
            fullTank INTEGER NOT NULL DEFAULT 1,
            station TEXT,
            notes TEXT,
            FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
          )
        ''');
      }
    } catch (e) {
      debugPrint('Error upgrading database: $e');
      rethrow;
    }
  }

  static Database get database {
    if (_database == null) {
      throw Exception('Database not initialized');
    }
    return _database!;
  }

  // Debug method to check table contents
  static Future<void> debugTables() async {
    final db = database;
    final tables = await db
        .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);

    for (var table in tables) {
      final tableName = table['name'] as String;
      if (tableName != 'android_metadata' && tableName != 'sqlite_sequence') {
        final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
        debugPrint('Table $tableName has $count records');

        final records = await db.query(tableName);
        debugPrint('Sample records from $tableName: ${records.take(2)}');
      }
    }
  }

  static Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, dbName);

    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await deleteDatabase(dbPath);
    await initialize();
    debugPrint('Database reset completed');
  }

  static Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return path.join(databasesPath, dbName);
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

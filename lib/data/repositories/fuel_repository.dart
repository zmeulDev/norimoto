import 'dart:async';
import 'package:norimoto/core/services/database_service.dart';
import 'package:norimoto/domain/models/fuel_record.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class FuelRepository {
  static final _fuelRecordsController =
      StreamController<List<FuelRecord>>.broadcast();
  static List<FuelRecord> _cachedRecords = [];

  static Stream<List<FuelRecord>> get fuelRecordsStream =>
      _fuelRecordsController.stream;

  static Future<List<FuelRecord>> getAllFuelRecords() async {
    try {
      final db = DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'fuel_records',
        orderBy: 'date DESC',
      );
      debugPrint('Raw fuel records from DB: ${maps.length}');
      debugPrint('Sample record: ${maps.isNotEmpty ? maps.first : "none"}');

      _cachedRecords = maps.map((map) => FuelRecord.fromJson(map)).toList();
      debugPrint('Parsed fuel records: ${_cachedRecords.length}');
      if (_cachedRecords.isNotEmpty) {
        debugPrint('Sample vehicleId: ${_cachedRecords.first.vehicleId}');
      }

      _fuelRecordsController.add(_cachedRecords);
      return _cachedRecords;
    } catch (e) {
      debugPrint('Error getting fuel records: $e');
      return [];
    }
  }

  static Future<List<FuelRecord>> getVehicleFuelRecords(
      String vehicleId) async {
    try {
      final records =
          _cachedRecords.where((r) => r.vehicleId == vehicleId).toList();
      debugPrint(
          'Filtered fuel records for vehicle $vehicleId: ${records.length}');
      return records;
    } catch (e) {
      debugPrint('Error getting vehicle fuel records: $e');
      return [];
    }
  }

  static Future<void> insertFuelRecord(FuelRecord record) async {
    try {
      final db = DatabaseService.database;
      debugPrint('Inserting fuel record: ${record.toJson()}');
      await db.insert(
        'fuel_records',
        record.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await getAllFuelRecords();
    } catch (e) {
      debugPrint('Error inserting fuel record: $e');
    }
  }

  static Future<void> updateFuelRecord(FuelRecord record) async {
    try {
      final db = DatabaseService.database;
      debugPrint('Updating fuel record: ${record.toJson()}');
      await db.update(
        'fuel_records',
        record.toJson(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      await getAllFuelRecords();
    } catch (e) {
      debugPrint('Error updating fuel record: $e');
    }
  }

  static Future<void> deleteFuelRecord(String id) async {
    try {
      final db = DatabaseService.database;
      debugPrint('Deleting fuel record: $id');
      await db.delete(
        'fuel_records',
        where: 'id = ?',
        whereArgs: [id],
      );
      await getAllFuelRecords();
    } catch (e) {
      debugPrint('Error deleting fuel record: $e');
    }
  }

  static Future<Map<String, double>> getVehicleStatistics(
      String vehicleId) async {
    try {
      final records = await getVehicleFuelRecords(vehicleId);
      if (records.isEmpty) {
        return {
          'totalCost': 0,
          'totalLiters': 0,
          'averageCost': 0,
          'averageConsumption': 0,
        };
      }

      records.sort((a, b) => a.date.compareTo(b.date));

      double totalCost = 0;
      double totalLiters = 0;
      double totalDistance = 0;

      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        totalCost += record.cost;
        totalLiters += record.liters;

        if (i > 0) {
          totalDistance += (record.odometer - records[i - 1].odometer);
        }
      }

      return {
        'totalCost': totalCost,
        'totalLiters': totalLiters,
        'averageCost': totalCost / totalLiters,
        'averageConsumption':
            totalDistance > 0 ? (totalLiters * 100) / totalDistance : 0,
      };
    } catch (e) {
      debugPrint('Error calculating vehicle statistics: $e');
      return {
        'totalCost': 0,
        'totalLiters': 0,
        'averageCost': 0,
        'averageConsumption': 0,
      };
    }
  }

  static void dispose() {
    _fuelRecordsController.close();
  }
}

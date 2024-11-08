import 'dart:async';
import 'package:norimoto/core/services/database_service.dart';
import 'package:norimoto/domain/models/vehicle.dart';
import 'package:sqflite/sqflite.dart';
import 'package:norimoto/data/repositories/service_repository.dart';
import 'package:norimoto/data/repositories/fuel_repository.dart';

class VehicleRepository {
  static final _vehiclesController =
      StreamController<List<Vehicle>>.broadcast();

  static Stream<List<Vehicle>> get vehiclesStream => _vehiclesController.stream;

  static Future<List<Vehicle>> getAllVehicles() async {
    final db = DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      orderBy: 'make ASC, model ASC',
    );
    final vehicles = maps.map((map) => Vehicle.fromJson(map)).toList();
    _vehiclesController.add(vehicles);
    return vehicles;
  }

  static Future<Vehicle?> getVehicle(String id) async {
    final db = DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Vehicle.fromJson(maps.first);
  }

  static Future<void> insertVehicle(Vehicle vehicle) async {
    final db = DatabaseService.database;
    final vehicleMap = vehicle.toJson();
    vehicleMap.removeWhere((key, value) => value == null);

    await db.insert(
      'vehicles',
      vehicleMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await getAllVehicles(); // Refresh the stream
  }

  static Future<void> updateVehicle(Vehicle vehicle) async {
    final db = DatabaseService.database;
    final vehicleMap = vehicle.toJson();
    vehicleMap.removeWhere((key, value) => value == null);

    await db.update(
      'vehicles',
      vehicleMap,
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
    await getAllVehicles(); // Refresh the stream
  }

  static Future<void> deleteVehicle(String id) async {
    final db = DatabaseService.database;

    // Start a transaction to ensure all operations complete or none do
    await db.transaction((txn) async {
      // Delete the vehicle
      await txn.delete(
        'vehicles',
        where: 'id = ?',
        whereArgs: [id],
      );

      // Delete related service records
      await txn.delete(
        'service_records',
        where: 'vehicleId = ?',
        whereArgs: [id],
      );

      // Delete related fuel records
      await txn.delete(
        'fuel_records',
        where: 'vehicleId = ?',
        whereArgs: [id],
      );
    });

    // Refresh all streams
    await getAllVehicles();
    await ServiceRepository.getAllServices();
    await FuelRepository.getAllFuelRecords();
  }

  static void dispose() {
    _vehiclesController.close();
  }
}

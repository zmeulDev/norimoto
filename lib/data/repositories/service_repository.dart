import 'dart:async';
import 'package:norimoto/core/services/database_service.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:sqflite/sqflite.dart';

class ServiceRepository {
  static final _servicesController =
      StreamController<List<ServiceRecord>>.broadcast();

  static Stream<List<ServiceRecord>> get servicesStream =>
      _servicesController.stream;

  static Future<List<ServiceRecord>> getAllServices() async {
    final db = DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'service_records',
      orderBy: 'date DESC',
    );
    final services = maps.map((map) => ServiceRecord.fromJson(map)).toList();
    _servicesController.add(services);
    return services;
  }

  static Future<List<ServiceRecord>> getVehicleServices(
      String vehicleId) async {
    final db = DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'service_records',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => ServiceRecord.fromJson(map)).toList();
  }

  static Future<void> insertService(ServiceRecord service) async {
    final db = DatabaseService.database;
    final serviceMap = service.toJson();
    serviceMap.removeWhere((key, value) => value == null);

    await db.insert(
      'service_records',
      serviceMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await getAllServices();
  }

  static Future<void> updateService(ServiceRecord service) async {
    final db = DatabaseService.database;
    final serviceMap = service.toJson();
    serviceMap.removeWhere((key, value) => value == null);

    await db.update(
      'service_records',
      serviceMap,
      where: 'id = ?',
      whereArgs: [service.id],
    );
    await getAllServices();
  }

  static Future<void> deleteService(String id) async {
    final db = DatabaseService.database;
    await db.delete(
      'service_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    await getAllServices();
  }

  static Future<List<ServiceRecord>> getUpcomingServices() async {
    final db = DatabaseService.database;
    final now = DateTime.now();
    final List<Map<String, dynamic>> maps = await db.query(
      'service_records',
      where: 'reminderDate >= ?',
      whereArgs: [now.toIso8601String()],
      orderBy: 'reminderDate ASC',
    );
    return maps.map((map) => ServiceRecord.fromJson(map)).toList();
  }

  static void dispose() {
    _servicesController.close();
  }
}

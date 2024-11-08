import 'dart:async';
import 'package:flutter/material.dart';
import 'package:norimoto/app/app.dart';
import 'package:norimoto/core/services/database_service.dart';
import 'package:norimoto/core/services/notification_service.dart';
import 'package:norimoto/data/repositories/vehicle_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:norimoto/core/services/backup_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Check and request permissions
    await _checkPermissions();

    // Initialize services
    try {
      await DatabaseService.initialize();
      debugPrint('Database initialized successfully');

      // Check auto backup
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('autoBackup') ?? false) {
        await BackupService.startAutoBackup();
      }

      // Initialize notifications after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        NotificationService.initialize().then((_) {
          debugPrint('Notifications initialized successfully');
        }).catchError((e) {
          debugPrint('Error initializing notifications: $e');
        });
      });
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }

    // Run the app
    runApp(const NorimotoApp());

    // Handle stream disposal when app is closed
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detached: () {
          VehicleRepository.dispose();
          return Future.value();
        },
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

Future<void> _checkPermissions() async {
  // Create list of required permissions
  final permissions = [
    Permission.notification,
    Permission.storage,
  ];

  // Check each permission
  Map<Permission, PermissionStatus> statuses = {};
  for (var permission in permissions) {
    statuses[permission] = await permission.status;
  }

  // Request permissions that aren't granted
  for (var entry in statuses.entries) {
    if (!entry.value.isGranted) {
      debugPrint('Requesting permission: ${entry.key}');
      final status = await entry.key.request();
      debugPrint('Permission ${entry.key} status: $status');
    }
  }

  // Additional check for Android 11+ storage permission
  if (await Permission.manageExternalStorage.status.isDenied) {
    await Permission.manageExternalStorage.request();
  }

  // Log final permission statuses
  for (var permission in permissions) {
    final status = await permission.status;
    debugPrint('Final ${permission.toString()} status: $status');
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function() detached;

  LifecycleEventHandler({
    required this.detached,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        await detached();
        break;
      default:
        break;
    }
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:norimoto/app/app.dart';
import 'package:norimoto/core/services/database_service.dart';
import 'package:norimoto/core/services/notification_service.dart';
import 'package:norimoto/data/repositories/vehicle_repository.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize services
    try {
      await DatabaseService.initialize();
      debugPrint('Database initialized successfully');

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
    runApp(const CarMaintenanceApp());

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

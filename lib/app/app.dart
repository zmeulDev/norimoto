import 'package:flutter/material.dart';
import 'package:norimoto/presentation/theme/app_theme.dart';
import 'package:norimoto/presentation/routes/app_router.dart';
import 'package:norimoto/core/services/notification_service.dart';

class CarMaintenanceApp extends StatelessWidget {
  const CarMaintenanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Car Maintenance Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.home,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:norimoto/presentation/theme/app_theme.dart';
import 'package:norimoto/presentation/routes/app_router.dart';
import 'package:norimoto/core/services/notification_service.dart';

class NorimotoApp extends StatelessWidget {
  const NorimotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Norimoto',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.home,
    );
  }
}

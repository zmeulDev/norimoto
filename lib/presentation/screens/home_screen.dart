import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bottom_nav.dart';
import 'package:norimoto/presentation/screens/vehicles_screen.dart';
import 'package:norimoto/presentation/screens/services_screen.dart';
import 'package:norimoto/presentation/screens/statistics_screen.dart';
import 'package:norimoto/presentation/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    VehiclesScreen(),
    ServicesScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

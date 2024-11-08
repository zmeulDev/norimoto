import 'package:flutter/material.dart';
import 'package:norimoto/presentation/theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.grey,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: AppTheme.white,
            unselectedItemColor: AppTheme.white.withOpacity(0.5),
            items: [
              _buildNavItem(
                icon: Icons.directions_car_outlined,
                activeIcon: Icons.directions_car,
                label: 'Vehicles',
                context: context,
              ),
              _buildNavItem(
                icon: Icons.build_outlined,
                activeIcon: Icons.build,
                label: 'Services',
                context: context,
              ),
              _buildNavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'Stats',
                context: context,
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required BuildContext context,
  }) {
    final isSelected = items.indexOf(label) == currentIndex;

    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: 24,
        ),
      ),
      label: label,
    );
  }

  List<String> get items => const ['Vehicles', 'Services', 'Stats', 'Settings'];
}

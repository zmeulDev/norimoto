import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/core/services/database_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(
        title: 'Settings',
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Reset Database'),
            subtitle: const Text('Warning: This will delete all data'),
            leading: const Icon(Icons.warning_amber_rounded),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Database'),
                  content: const Text(
                    'Are you sure you want to reset the database? '
                    'This will delete all your data and cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );

              if (confirmed ?? false) {
                await DatabaseService.resetDatabase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Database reset successfully')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

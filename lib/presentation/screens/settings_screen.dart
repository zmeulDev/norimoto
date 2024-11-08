import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/core/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:norimoto/core/services/backup_service.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoBackup = false;
  bool _isLoading = false;
  DateTime? _lastBackupDate;
  String? _customBackupPath;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoBackup = prefs.getBool('autoBackup') ?? false;
      _customBackupPath = prefs.getString('customBackupPath');
      final lastBackup = prefs.getString('lastBackupDate');
      _lastBackupDate = lastBackup != null ? DateTime.parse(lastBackup) : null;
    });
  }

  Future<void> _selectBackupLocation() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Backup Location',
        lockParentWindow: true,
      );

      if (selectedDirectory != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customBackupPath', selectedDirectory);
        setState(() => _customBackupPath = selectedDirectory);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Backup location set to: ${_getLocationDisplayName(selectedDirectory)}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting backup location: $e')),
        );
      }
    }
  }

  String _getLocationDisplayName(String path) {
    if (path.contains('Android/data')) {
      return 'App Storage';
    } else if (path.contains('Documents')) {
      return 'Documents';
    } else if (path.contains('Download')) {
      return 'Downloads';
    } else {
      return path.split('/').last;
    }
  }

  String _getBackupLocationText() {
    if (_customBackupPath == null) {
      return 'App Documents (Default)';
    }
    return _getLocationDisplayName(_customBackupPath!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(
        title: 'Settings',
      ),
      body: ListView(
        children: [
          _buildBackupSection(),
          const Divider(),
          _buildDatabaseSection(),
        ],
      ),
    );
  }

  Widget _buildBackupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Backup & Restore',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListTile(
          title: const Text('Backup Location'),
          subtitle: Text(_getBackupLocationText()),
          leading: const Icon(Icons.folder),
          trailing: _customBackupPath != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('customBackupPath');
                    setState(() => _customBackupPath = null);
                  },
                )
              : null,
          onTap: _selectBackupLocation,
        ),
        SwitchListTile(
          title: const Text('Auto Backup'),
          subtitle: const Text('Automatically backup data daily'),
          value: _autoBackup,
          onChanged: _toggleAutoBackup,
        ),
        ListTile(
          title: const Text('Manual Backup'),
          subtitle: _lastBackupDate != null
              ? Text(
                  'Last backup: ${_getLastBackupText()}',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : const Text('No backups yet'),
          leading: const Icon(Icons.backup),
          trailing: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: _isLoading ? null : _backupData,
        ),
        ListTile(
          title: const Text('Restore Backup'),
          subtitle: const Text('Restore data from cloud backup'),
          leading: const Icon(Icons.restore),
          onTap: _isLoading ? null : _showRestoreDialog,
        ),
        ListTile(
          title: const Text('Backup History'),
          subtitle: const Text('View and manage backups'),
          leading: const Icon(Icons.history),
          onTap: _isLoading ? null : _showBackupHistory,
        ),
      ],
    );
  }

  Widget _buildDatabaseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Database',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListTile(
          title: const Text('Reset Database'),
          subtitle: const Text('Warning: This will delete all data'),
          leading: const Icon(Icons.warning_amber_rounded),
          onTap: _showResetDatabaseDialog,
        ),
      ],
    );
  }

  String _getLastBackupText() {
    if (_lastBackupDate == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(_lastBackupDate!);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _toggleAutoBackup(bool value) async {
    setState(() => _autoBackup = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoBackup', value);

    if (value) {
      // Start first auto backup immediately when enabled
      await BackupService.startAutoBackup();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Auto backup enabled' : 'Auto backup disabled',
          ),
        ),
      );
    }
  }

  Future<void> _backupData() async {
    setState(() => _isLoading = true);

    try {
      final backupPath = await BackupService.createBackup();

      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      await prefs.setString('lastBackupDate', now.toIso8601String());

      setState(() => _lastBackupDate = now);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved to: ${path.basename(backupPath)}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showRestoreDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'Choose a backup file to restore. This will replace all current data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Choose File'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final backupPath = await BackupService.selectBackupFile();
      if (backupPath != null && mounted) {
        await _restoreFromFile(backupPath);
      }
    }
  }

  Future<void> _restoreFromFile(String backupPath) async {
    setState(() => _isLoading = true);

    try {
      await BackupService.restoreBackup(backupPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showBackupHistory() async {
    try {
      final backups = await BackupService.getBackupHistory();

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Backup History'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: backups.map((backup) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              DateFormat.yMMMd()
                                  .add_Hm()
                                  .format(backup.timestamp),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Chip(
                              label: Text(
                                backup.isAuto ? 'Auto' : 'Manual',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: backup.isAuto
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Location: ${backup.displayLocation}'),
                        Text(
                            'Size: ${(backup.size / 1024).toStringAsFixed(1)} KB'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.restore),
                              label: const Text('Restore'),
                              onPressed: () async {
                                Navigator.pop(context);
                                await BackupService.restoreBackup(backup.path);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Restore completed successfully')),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                              onPressed: () async {
                                await BackupService.deleteBackup(backup.path);
                                Navigator.pop(context);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Backup deleted')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading backup history: $e')),
        );
      }
    }
  }

  Future<void> _showResetDatabaseDialog() async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database reset successfully')),
        );
      }
    }
  }
}

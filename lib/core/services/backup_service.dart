import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:norimoto/core/services/database_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static const String backupFolder = 'norimoto_backups';
  static const Duration autoBackupInterval = Duration(hours: 24);

  static Future<void> startAutoBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAutoBackup = prefs.getString('lastAutoBackupDate');
    final now = DateTime.now();

    if (lastAutoBackup != null) {
      final lastBackupDate = DateTime.parse(lastAutoBackup);
      if (now.difference(lastBackupDate) < autoBackupInterval) {
        // Not time for auto backup yet
        return;
      }
    }

    try {
      await createAutoBackup();
      await prefs.setString('lastAutoBackupDate', now.toIso8601String());
    } catch (e) {
      debugPrint('Auto backup failed: $e');
    }
  }

  static Future<String> createAutoBackup() async {
    try {
      // Get database file
      final dbFile = File(await DatabaseService.getDatabasePath());
      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      // Use app documents directory for auto backups
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory(path.join(appDir.path, backupFolder));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Create backup archive with auto prefix
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupName = 'auto_backup_$timestamp.zip';
      final backupPath = path.join(backupDir.path, backupName);

      // Create zip file
      final encoder = ZipEncoder();
      final archive = Archive();

      // Add database file to archive
      final dbBytes = await dbFile.readAsBytes();
      final dbFileArchive = ArchiveFile(
        'database.db',
        dbBytes.length,
        dbBytes,
      );
      archive.addFile(dbFileArchive);

      // Write zip file
      final backupFile = File(backupPath);
      await backupFile.writeAsBytes(encoder.encode(archive)!);

      return backupPath;
    } catch (e) {
      debugPrint('Error creating auto backup: $e');
      rethrow;
    }
  }

  static Future<String> createBackup() async {
    try {
      // Get database file
      final dbFile = File(await DatabaseService.getDatabasePath());
      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      // Let user select backup location
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Backup Location',
        lockParentWindow: true,
      );

      if (selectedDirectory == null) {
        throw Exception('No directory selected');
      }

      // Create backup directory inside selected location
      final backupDir = Directory(path.join(selectedDirectory, backupFolder));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Save backup location for history
      final prefs = await SharedPreferences.getInstance();
      final backupLocations = prefs.getStringList('backupLocations') ?? [];
      if (!backupLocations.contains(selectedDirectory)) {
        backupLocations.add(selectedDirectory);
        await prefs.setStringList('backupLocations', backupLocations);
      }

      // Create backup archive with manual prefix
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupName = 'manual_backup_$timestamp.zip';
      final backupPath = path.join(backupDir.path, backupName);

      // Create zip file
      final encoder = ZipEncoder();
      final archive = Archive();

      // Add database file to archive
      final dbBytes = await dbFile.readAsBytes();
      final dbFileArchive = ArchiveFile(
        'database.db',
        dbBytes.length,
        dbBytes,
      );
      archive.addFile(dbFileArchive);

      // Write zip file
      final backupFile = File(backupPath);
      await backupFile.writeAsBytes(encoder.encode(archive)!);

      return backupPath;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      rethrow;
    }
  }

  static Future<List<BackupInfo>> getBackupHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupLocations = prefs.getStringList('backupLocations') ?? [];
      final List<BackupInfo> allBackups = [];

      // Add default app documents location
      final appDir = await getApplicationDocumentsDirectory();
      backupLocations.add(appDir.path);

      // Get backups from all saved locations
      for (final location in backupLocations) {
        final backupDir = Directory(path.join(location, backupFolder));
        if (await backupDir.exists()) {
          final files = await backupDir.list().toList();
          for (var file in files) {
            if (file is File && file.path.endsWith('.zip')) {
              final stat = await file.stat();
              allBackups.add(BackupInfo(
                name: path.basename(file.path),
                path: file.path,
                location: location,
                timestamp: stat.modified,
                size: stat.size,
              ));
            }
          }
        }
      }

      // Sort by timestamp, newest first
      allBackups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allBackups;
    } catch (e) {
      debugPrint('Error getting backup history: $e');
      rethrow;
    }
  }

  static Future<void> restoreBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }

      // Verify it's a valid backup file
      if (!backupPath.endsWith('.zip')) {
        throw Exception('Invalid backup file format');
      }

      // Extract backup
      final bytes = await backupFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find database file in archive
      final dbFile = archive.findFile('database.db');
      if (dbFile == null)
        throw Exception('Invalid backup file: No database found');

      // Close current database connection
      await DatabaseService.close();

      // Write restored database file
      final dbPath = await DatabaseService.getDatabasePath();
      final restoredDb = File(dbPath);
      await restoredDb.writeAsBytes(dbFile.content as List<int>);

      // Reinitialize database
      await DatabaseService.initialize();
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      rethrow;
    }
  }

  static Future<void> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      rethrow;
    }
  }

  static Future<String?> selectBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        dialogTitle: 'Select Backup File to Restore',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (!await file.exists()) {
          throw Exception('Selected file does not exist');
        }
        if (!file.path.endsWith('.zip')) {
          throw Exception(
              'Invalid file format. Please select a .zip backup file');
        }
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error selecting backup file: $e');
      rethrow;
    }
  }

  static bool isAutoBackup(String fileName) {
    return fileName.startsWith('auto_backup_');
  }
}

class BackupInfo {
  final String name;
  final String path;
  final String location;
  final DateTime timestamp;
  final int size;
  final bool isAuto;

  BackupInfo({
    required this.name,
    required this.path,
    required this.location,
    required this.timestamp,
    required this.size,
  }) : isAuto = name.startsWith('auto_backup_');

  String get displayLocation => path.contains('Documents')
      ? 'App Documents'
      : path.split('/').reversed.skip(1).first;

  String get displayName => isAuto ? 'Auto Backup' : 'Manual Backup';
}

import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../database/database_helper.dart';
import '../services/export_service.dart';
import 'package:provider/provider.dart';
import 'notification_sound_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final tasks = await dbHelper.getAllTasks();
      final exportService = ExportService.instance;
      await exportService.shareCSV(tasks, dbHelper);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tasks exported to CSV')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final tasks = await dbHelper.getAllTasks();
      final exportService = ExportService.instance;
      await exportService.sharePDF(tasks, dbHelper);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tasks exported to PDF')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Notifications Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'NOTIFICATIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00BCD4),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Sound'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSoundScreen(),
                  ),
                );
              },
            ),
          ),
          // Data Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'DATA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00BCD4),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.description, color: Colors.green),
              title: const Text('Export to CSV'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _exportToCSV(context),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export to PDF'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _exportToPDF(context),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final int initialMinutes;

  const NotificationSettingsScreen({super.key, required this.initialMinutes});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.initialMinutes;
  }

  final List<int> _options = [0, 5, 10, 15, 30, 60];

  String _getText(int minutes) {
    if (minutes == 0) return 'At time';
    if (minutes < 60) return '$minutes minutes before';
    return '${minutes ~/ 60} hour${minutes > 60 ? 's' : ''} before';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _selectedMinutes),
        ),
        title: const Text('Notification'),
      ),
      body: ListView(
        children: _options.map((minutes) {
          return RadioListTile<int>(
            title: Text(_getText(minutes)),
            value: minutes,
            groupValue: _selectedMinutes,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedMinutes = value);
                Navigator.pop(context, _selectedMinutes);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

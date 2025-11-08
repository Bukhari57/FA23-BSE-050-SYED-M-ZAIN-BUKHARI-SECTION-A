import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SoundService {
  static final SoundService instance = SoundService._init();
  static const String _soundKey = 'notificationSound';
  static const String _customSoundPathKey = 'customSoundPath';
  
  static const String defaultSound = 'default';
  static const String customSound = 'custom';

  SoundService._init();

  Future<String> getSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_soundKey) ?? defaultSound;
    return (value == defaultSound || value == customSound) ? value : defaultSound;
  }

  Future<void> setSelectedSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundKey, sound);
  }

  Future<String?> getCustomSoundPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customSoundPathKey);
  }

  Future<void> setCustomSoundPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null && path.isNotEmpty) {
      await prefs.setString(_customSoundPathKey, path);
    } else {
      await prefs.remove(_customSoundPathKey);
    }
  }

  static List<Map<String, String>> getAvailableSounds() {
    return [
      {'id': defaultSound, 'name': 'Default', 'description': 'System default notification sound'},
      {'id': customSound, 'name': 'Custom', 'description': 'Select a sound file from your device'},
    ];
  }

  Future<AndroidNotificationSound?> getAndroidSoundUri(String soundId) async {
    switch (soundId) {
      case defaultSound:
        return null; // Use channel/app default
      case customSound:
        final customPath = await getCustomSoundPath();
        if (customPath != null && customPath.isNotEmpty) {
          String uri = customPath;
          if (!uri.startsWith('file://') && !uri.startsWith('content://')) {
            uri = 'file://$uri';
          }
          return UriAndroidNotificationSound(uri);
        }
        return null;
      default:
        return null;
    }
  }

  String getChannelId(String soundId) {
    return 'task_notifications';
  }
}


import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';
import 'sound_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels first (required for Android 8.0+)
    await _createNotificationChannels();

    // Request permissions for Android 12+ (must be after channel creation)
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final permissionGranted = await android.requestNotificationsPermission();
      if (permissionGranted == false) {
        // Request exact alarm permission for Android 12+
        await android.requestExactAlarmsPermission();
      }
    }
  }

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final notificationPermission = await android.requestNotificationsPermission();
      final alarmPermission = await android.requestExactAlarmsPermission();
      return (notificationPermission ?? false) && (alarmPermission ?? false);
    }
    return true;
  }

  Future<bool> checkPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final notificationsEnabled = await android.areNotificationsEnabled();
      return notificationsEnabled ?? false;
    }
    return true;
  }

  Future<void> _createNotificationChannels() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      // Create main notification channel (for default and system sounds)
      try {
        await android.deleteNotificationChannel('task_notifications');
      } catch (e) {
        // Channel doesn't exist, continue
      }

      const mainChannel = AndroidNotificationChannel(
        'task_notifications',
        'Task Notifications',
        description: 'Notifications for upcoming tasks. Sound enabled by default.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      
      await android.createNotificationChannel(mainChannel);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (task.dueTime == null) return;

    final dueDateTime = _getTaskDateTime(task);
    if (dueDateTime.isBefore(DateTime.now())) return;

    final notificationTime = dueDateTime.subtract(
      Duration(minutes: task.notificationMinutesBefore),
    );

    if (notificationTime.isBefore(DateTime.now())) return;

    // Check if permissions are granted
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      // Try to request permission if not granted
      await requestPermissions();
      return;
    }

    // Get selected sound
    final soundService = SoundService.instance;
    final selectedSound = await soundService.getSelectedSound();
    // With only default/custom options, sound is always intended to play
    final playSound = true;
    final androidSound = await soundService.getAndroidSoundUri(selectedSound);

    // Use the channel ID
    const channelId = 'task_notifications';

    // Create Android notification details with proper sound configuration
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Task Notifications',
      channelDescription: 'Notifications for upcoming tasks',
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: playSound,
      channelShowBadge: true,
      autoCancel: true,
      ongoing: false,
      sound: androidSound, // Use the specific sound URI
    );

    await _notifications.zonedSchedule(
      task.id ?? DateTime.now().millisecondsSinceEpoch,
      task.title,
      task.description,
      tz.TZDateTime.from(notificationTime, tz.local),
      NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: playSound,
          sound: playSound ? 'default' : null,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskNotification(int taskId) async {
    await _notifications.cancel(taskId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  DateTime _getTaskDateTime(Task task) {
    final dueDate = task.dueDate;
    if (task.dueTime != null) {
      final timeParts = task.dueTime!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      return DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        hour,
        minute,
      );
    }
    return dueDate;
  }
}

# TaskFlow - Task Management Application

A comprehensive Flutter task management application with SQLite database, local notifications, and export functionality.

## Features

### Core Functionality
- **Task Management**: Create, edit, delete, and complete tasks
- **Today View**: View all tasks due today
- **Completed View**: Track completed tasks
- **Repeated Tasks**: Support for daily, weekly, and custom repeat patterns
- **Subtasks**: Break down tasks into smaller steps with progress tracking

### Advanced Features
- **Dark Mode**: Toggle between light and dark themes
- **Local Notifications**: Get notified before task due times
- **Export Options**: Export tasks to CSV or PDF format
- **Task Details**: Detailed view with subtask progress
- **Custom Repeat**: Set tasks to repeat on specific days of the week

## Project Structure

```
lib/
├── models/
│   ├── task.dart          # Task data model
│   └── subtask.dart       # Subtask data model
├── database/
│   └── database_helper.dart  # SQLite database operations
├── services/
│   ├── theme_service.dart     # Theme management
│   ├── notification_service.dart  # Local notifications
│   └── export_service.dart    # CSV/PDF export
├── screens/
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── today_view.dart
│   ├── completed_view.dart
│   ├── repeated_view.dart
│   ├── new_task_screen.dart
│   ├── task_detail_screen.dart
│   ├── subtasks_screen.dart
│   ├── notification_settings_screen.dart
│   └── settings_screen.dart
├── utils/
│   └── repeat_helper.dart     # Task repetition logic
└── main.dart
```

## Dependencies

- `sqflite`: SQLite database
- `path_provider`: File system access
- `intl`: Date and time formatting
- `flutter_local_notifications`: Local notifications
- `timezone`: Timezone support
- `shared_preferences`: User preferences
- `provider`: State management
- `share_plus`: File sharing
- `pdf`: PDF generation
- `csv`: CSV generation

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd task_manager_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## Building APK

To build an APK file:

```bash
flutter build apk --release
```

The APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

## Permissions

The app requires the following Android permissions:
- `RECEIVE_BOOT_COMPLETED`: To reschedule notifications after device restart
- `VIBRATE`: For notification vibrations
- `SCHEDULE_EXACT_ALARM`: For precise notification scheduling
- `POST_NOTIFICATIONS`: For displaying notifications (Android 12+)

## Features Documentation

### Task Creation
- Title and description
- Due date and time selection
- Repeat options (None, Daily, Weekly, Custom)
- Notification timing
- Subtasks management

### Task Repetition
- **None**: One-time task
- **Daily**: Repeats every day
- **Weekly**: Repeats on the same weekday
- **Custom**: Select specific days of the week

### Notifications
- Configurable notification time (0, 5, 10, 15, 30, or 60 minutes before)
- Automatic scheduling based on task due date and time
- Notifications cancel automatically when tasks are completed

### Export
- **CSV Export**: Export all tasks with details to CSV format
- **PDF Export**: Generate a formatted PDF document with all tasks
- Share exported files via email or other apps

## Testing

Run tests with:
```bash
flutter test
```

## Notes

- The app uses local storage (SQLite) - no internet connection required
- Notifications work offline
- All data is stored locally on the device
- Dark mode preference is saved across app restarts

## Future Enhancements

- Notification sound selection
- Task categories/tags
- Search functionality
- Calendar integration
- Task reminders
- Data backup/restore

## License

This project is for educational purposes.

## Support

For issues or questions, please refer to the project documentation or contact the development team.
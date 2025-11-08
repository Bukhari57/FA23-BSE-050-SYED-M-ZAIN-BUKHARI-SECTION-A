import 'dart:convert';
import '../models/task.dart';

class RepeatHelper {
  static List<int> parseRepeatDays(String? repeatDaysJson) {
    if (repeatDaysJson == null || repeatDaysJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(repeatDaysJson);
      return decoded.cast<int>();
    } catch (e) {
      return [];
    }
  }

  static String encodeRepeatDays(List<int> days) {
    return jsonEncode(days);
  }

  static bool shouldRepeatToday(Task task, DateTime today) {
    switch (task.repeatType) {
      case RepeatType.none:
        return false;
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        final taskDay = task.dueDate.weekday;
        return today.weekday == taskDay;
      case RepeatType.custom:
        final repeatDays = parseRepeatDays(task.repeatDays);
        return repeatDays.contains(today.weekday);
    }
  }

  static DateTime? getNextRepeatDate(Task task, DateTime fromDate) {
    switch (task.repeatType) {
      case RepeatType.none:
        return null;
      case RepeatType.daily:
        return fromDate.add(const Duration(days: 1));
      case RepeatType.weekly:
        return fromDate.add(const Duration(days: 7));
      case RepeatType.custom:
        final repeatDays = parseRepeatDays(task.repeatDays);
        if (repeatDays.isEmpty) return null;
        
        // Find next day in the repeat days list
        for (int i = 1; i <= 7; i++) {
          final nextDate = fromDate.add(Duration(days: i));
          if (repeatDays.contains(nextDate.weekday)) {
            return nextDate;
          }
        }
        return fromDate.add(const Duration(days: 7));
    }
  }
}

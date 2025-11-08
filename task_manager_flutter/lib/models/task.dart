class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String? dueTime;
  final bool isCompleted;
  final RepeatType repeatType;
  final String? repeatDays; // JSON string for custom days
  final int notificationMinutesBefore; // e.g., 15 for 15 minutes before
  final DateTime createdAt;
  final DateTime? completedAt;
  final TaskPriority priority;
  final String? category;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    this.repeatType = RepeatType.none,
    this.repeatDays,
    this.notificationMinutesBefore = 15,
    required this.createdAt,
    this.completedAt,
    this.priority = TaskPriority.medium,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime,
      'isCompleted': isCompleted ? 1 : 0,
      'repeatType': repeatType.toString().split('.').last,
      'repeatDays': repeatDays,
      'notificationMinutesBefore': notificationMinutesBefore,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'category': category,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      dueTime: map['dueTime'] as String?,
      isCompleted: (map['isCompleted'] as int) == 1,
      repeatType: RepeatType.values.firstWhere(
        (e) => e.toString().split('.').last == map['repeatType'],
        orElse: () => RepeatType.none,
      ),
      repeatDays: map['repeatDays'] as String?,
      notificationMinutesBefore: map['notificationMinutesBefore'] as int? ?? 15,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      priority: map['priority'] != null
          ? TaskPriority.values.firstWhere(
              (e) => e.toString().split('.').last == map['priority'],
              orElse: () => TaskPriority.medium,
            )
          : TaskPriority.medium,
      category: map['category'] as String?,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    bool? isCompleted,
    RepeatType? repeatType,
    String? repeatDays,
    int? notificationMinutesBefore,
    DateTime? createdAt,
    DateTime? completedAt,
    TaskPriority? priority,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      notificationMinutesBefore: notificationMinutesBefore ?? this.notificationMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }
}

enum TaskPriority {
  low,
  medium,
  high,
}

enum RepeatType {
  none,
  daily,
  weekly,
  custom,
}

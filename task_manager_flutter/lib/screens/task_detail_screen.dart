import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import 'new_task_screen.dart';
import 'subtasks_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;
  Task? _currentTask;
  int _completedSubtasks = 0;
  int _totalSubtasks = 0;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _loadSubtasks();
  }

  Future<void> _loadSubtasks() async {
    final subtasks = await _dbHelper.getSubtasksForTask(_currentTask!.id!);
    setState(() {
      _totalSubtasks = subtasks.length;
      _completedSubtasks = subtasks.where((s) => s.isCompleted).length;
    });
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _notificationService.cancelTaskNotification(_currentTask!.id!);
      await _dbHelper.deleteTask(_currentTask!.id!);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _markAsCompleted() async {
    // If marking a repeated task as completed, ask if user wants to stop repeating
    bool shouldDisableRepeat = false;
    if (!_currentTask!.isCompleted && _currentTask!.repeatType != RepeatType.none) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Complete Repeated Task'),
          content: const Text(
            'This task is set to repeat. Do you want to stop repeating it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Repeating'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Stop Repeating', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      shouldDisableRepeat = result ?? false;
    }

    final updatedTask = _currentTask!.copyWith(
      isCompleted: !_currentTask!.isCompleted,
      completedAt: !_currentTask!.isCompleted ? DateTime.now() : null,
      repeatType: shouldDisableRepeat ? RepeatType.none : _currentTask!.repeatType,
      repeatDays: shouldDisableRepeat ? null : _currentTask!.repeatDays,
    );
    await _dbHelper.updateTask(updatedTask);
    if (!updatedTask.isCompleted) {
      await _notificationService.scheduleTaskNotification(updatedTask);
    } else {
      await _notificationService.cancelTaskNotification(updatedTask.id!);
    }
    setState(() => _currentTask = updatedTask);
    _loadSubtasks();
  }

  String _getRepeatTypeText() {
    switch (_currentTask!.repeatType) {
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.custom:
        return 'Custom';
      default:
        return 'None';
    }
  }

  String _getPriorityText() {
    switch (_currentTask!.priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    String? timeDisplay;
    if (_currentTask!.dueTime != null) {
      final timeParts = _currentTask!.dueTime!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final dateTime = DateTime(2000, 1, 1, hour, minute);
      timeDisplay = timeFormat.format(dateTime);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewTaskScreen(task: _currentTask),
                ),
              );
              final updated = await _dbHelper.getTask(_currentTask!.id!);
              if (updated != null) {
                setState(() => _currentTask = updated);
                _loadSubtasks();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _currentTask!.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              _currentTask!.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            // Due Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(_currentTask!.dueDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (timeDisplay != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    timeDisplay,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
            if (_currentTask!.repeatType != RepeatType.none) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.repeat, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Repeat: ${_getRepeatTypeText()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _currentTask!.priority == TaskPriority.high
                      ? Icons.priority_high
                      : _currentTask!.priority == TaskPriority.medium
                          ? Icons.remove
                          : Icons.arrow_downward,
                  size: 20,
                  color: _currentTask!.priority == TaskPriority.high
                      ? Colors.red
                      : _currentTask!.priority == TaskPriority.medium
                          ? Colors.orange
                          : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Priority: ${_getPriorityText()}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _currentTask!.priority == TaskPriority.high
                        ? Colors.red
                        : _currentTask!.priority == TaskPriority.medium
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
              ],
            ),
            if (_currentTask!.category != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.category, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentTask!.category!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF00BCD4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            // Subtask Progress
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubtasksScreen(taskId: _currentTask!.id!),
                  ),
                );
                _loadSubtasks();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Subtask Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_completedSubtasks of $_totalSubtasks completed',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _totalSubtasks > 0
                          ? _completedSubtasks / _totalSubtasks
                          : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00BCD4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _markAsCompleted,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentTask!.isCompleted ? 'Mark as Incomplete' : 'Mark as Completed',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

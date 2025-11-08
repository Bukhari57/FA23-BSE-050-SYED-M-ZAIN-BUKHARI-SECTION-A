import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../utils/repeat_helper.dart';
import 'task_detail_screen.dart';

class TodayView extends StatefulWidget {
  const TodayView({super.key});

  @override
  State<TodayView> createState() => TodayViewState();
}

class TodayViewState extends State<TodayView> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTasks();
  }

  void refresh() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final today = DateTime.now();
    
    // Get tasks due today
    final tasksForToday = await _dbHelper.getTasksByDate(today);
    
    // Get all repeated tasks that should appear today
    final repeatedTasks = await _dbHelper.getRepeatedTasks();
    final todayRepeatedTasks = repeatedTasks.where((task) {
      return RepeatHelper.shouldRepeatToday(task, today);
    }).toList();
    
    // Combine both lists, avoiding duplicates
    final allTasks = <Task>[];
    final taskIds = <int>{};
    
    for (final task in tasksForToday) {
      if (!taskIds.contains(task.id)) {
        allTasks.add(task);
        taskIds.add(task.id!);
      }
    }
    
    for (final task in todayRepeatedTasks) {
      if (!taskIds.contains(task.id)) {
        allTasks.add(task);
        taskIds.add(task.id!);
      }
    }
    
    // Sort by time
    allTasks.sort((a, b) {
      if (a.dueTime == null && b.dueTime == null) return 0;
      if (a.dueTime == null) return 1;
      if (b.dueTime == null) return -1;
      return a.dueTime!.compareTo(b.dueTime!);
    });
    
    setState(() {
      _tasks = allTasks;
      _isLoading = false;
    });
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    // If marking a repeated task as completed, ask if user wants to stop repeating
    bool shouldDisableRepeat = false;
    if (!task.isCompleted && task.repeatType != RepeatType.none) {
      if (!mounted) return;
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

    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
      repeatType: shouldDisableRepeat ? RepeatType.none : task.repeatType,
      repeatDays: shouldDisableRepeat ? null : task.repeatDays,
    );
    await _dbHelper.updateTask(updatedTask);
    if (!mounted) return;
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _tasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(_tasks[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks for today',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final timeFormat = DateFormat('h:mm a');
    String? timeDisplay;
    if (task.dueTime != null) {
      final timeParts = task.dueTime!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final dateTime = DateTime(2000, 1, 1, hour, minute);
      timeDisplay = timeFormat.format(dateTime);
    }

    Color priorityColor = Colors.grey;
    IconData priorityIcon = Icons.circle;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        priorityIcon = Icons.remove;
        break;
      case TaskPriority.low:
        priorityColor = Colors.green;
        priorityIcon = Icons.arrow_downward;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(task: task),
            ),
          );
          if (mounted) {
            _loadTasks();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => _toggleTaskCompletion(task),
                activeColor: const Color(0xFF00BCD4),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: task.isCompleted ? Colors.grey : null,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(priorityIcon,
                              size: 16, color: priorityColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (timeDisplay != null) ...[
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            timeDisplay,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (task.category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF00BCD4).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.category!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF00BCD4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

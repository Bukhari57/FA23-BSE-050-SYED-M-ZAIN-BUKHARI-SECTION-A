import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import 'subtasks_screen.dart';
import 'notification_settings_screen.dart';
import '../utils/repeat_helper.dart';

class NewTaskScreen extends StatefulWidget {
  final Task? task;

  const NewTaskScreen({super.key, this.task});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;

  DateTime _dueDate = DateTime.now();
  String? _dueTime;
  RepeatType _repeatType = RepeatType.none;
  List<int> _customRepeatDays = [];
  int _notificationMinutesBefore = 15;
  int? _savedTaskId; // Track saved task ID for new tasks
  DateTime? _taskCreatedAt; // Track when task was first created (for silent saves)
  TaskPriority _priority = TaskPriority.medium;
  String? _category;
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _dueTime = widget.task!.dueTime;
      _repeatType = widget.task!.repeatType;
      _customRepeatDays = RepeatHelper.parseRepeatDays(widget.task!.repeatDays);
      _notificationMinutesBefore = widget.task!.notificationMinutesBefore;
      _savedTaskId = widget.task!.id;
      _priority = widget.task!.priority;
      _category = widget.task!.category;
      if (_category != null) {
        _categoryController.text = _category!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime != null
          ? TimeOfDay(
              hour: int.parse(_dueTime!.split(':')[0]),
              minute: int.parse(_dueTime!.split(':')[1]),
            )
          : TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _dueTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _selectRepeatType(RepeatType type) {
    setState(() {
      _repeatType = type;
      if (type == RepeatType.custom) {
        _showCustomRepeatDialog();
      }
    });
  }

  Future<void> _showCustomRepeatDialog() async {
    final selectedDays = await showDialog<List<int>>(
      context: context,
      builder: (context) => _CustomRepeatDialog(initialDays: _customRepeatDays),
    );
    if (selectedDays != null) {
      setState(() => _customRepeatDays = selectedDays);
      if (selectedDays.isEmpty) {
        _repeatType = RepeatType.none;
      }
    }
  }

  Future<int?> _saveTaskSilently() async {
    if (!_formKey.currentState!.validate()) return null;

    final task = Task(
      id: widget.task?.id ?? _savedTaskId,
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      dueTime: _dueTime,
      repeatType: _repeatType,
      repeatDays: _repeatType == RepeatType.custom && _customRepeatDays.isNotEmpty
          ? RepeatHelper.encodeRepeatDays(_customRepeatDays)
          : null,
      notificationMinutesBefore: _notificationMinutesBefore,
      createdAt: widget.task?.createdAt ?? _taskCreatedAt ?? DateTime.now(),
      isCompleted: widget.task?.isCompleted ?? false,
      completedAt: widget.task?.completedAt,
      priority: _priority,
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
    );

    int? taskId;
    if (task.id == null) {
      // New task - save it
      if (_taskCreatedAt == null) {
        _taskCreatedAt = task.createdAt;
      }
      taskId = await _dbHelper.insertTask(task);
      _savedTaskId = taskId;
      await _notificationService.scheduleTaskNotification(task.copyWith(id: taskId));
    } else {
      // Existing task - update it
      taskId = task.id;
      await _dbHelper.updateTask(task);
      await _notificationService.cancelTaskNotification(task.id!);
      await _notificationService.scheduleTaskNotification(task);
    }

    return taskId;
  }

  Future<void> _saveTask() async {
    final taskId = await _saveTaskSilently();
    if (taskId == null) return;

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF00BCD4),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Buy groceries',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Milk, bread, eggs...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Due Date
            const Text(
              'Due Date',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF00BCD4)),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(_dueDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Time
            const Text(
              'Time',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF00BCD4)),
                    const SizedBox(width: 12),
                    Text(
                      _dueTime ?? 'Select time',
                      style: TextStyle(
                        fontSize: 16,
                        color: _dueTime != null ? null : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Repeat
            const Text(
              'Repeat',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildRepeatButton('None', RepeatType.none),
                _buildRepeatButton('Daily', RepeatType.daily),
                _buildRepeatButton('Weekly', RepeatType.weekly),
                _buildRepeatButton('Custom', RepeatType.custom),
              ],
            ),
            const SizedBox(height: 24),
            // Priority
            const Text(
              'Priority',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPriorityButton('Low', TaskPriority.low, Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPriorityButton('Medium', TaskPriority.medium, Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPriorityButton('High', TaskPriority.high, Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Category
            const Text(
              'Category (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                hintText: 'e.g., Work, Personal, Health',
                prefixIcon: const Icon(Icons.category, color: Color(0xFF00BCD4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 32),
            // Subtasks
            InkWell(
              onTap: () async {
                // Get task ID - either from widget.task or from saved new task
                int? taskId = widget.task?.id ?? _savedTaskId;
                
                // If no task ID, save the task first
                if (taskId == null) {
                  taskId = await _saveTaskSilently();
                  if (taskId == null) {
                    // Validation failed, show message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in the required fields (Title and Description) before adding subtasks.'),
                        ),
                      );
                    }
                    return;
                  }
                }

                // Navigate to subtasks screen
                if (mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubtasksScreen(taskId: taskId!),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.list, color: Colors.black87),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subtasks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Add steps to complete your task',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Notification
            InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationSettingsScreen(
                      initialMinutes: _notificationMinutesBefore,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() => _notificationMinutesBefore = result);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.black87),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _notificationMinutesBefore == 0
                          ? 'At time'
                          : '$_notificationMinutesBefore minutes before',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF00BCD4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityButton(String label, TaskPriority priority, Color color) {
    final isSelected = _priority == priority;
    return InkWell(
      onTap: () => setState(() => _priority = priority),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatButton(String label, RepeatType type) {
    final isSelected = _repeatType == type;
    return InkWell(
      onTap: () => _selectRepeatType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BCD4).withValues(alpha: 0.2) : null,
          border: Border.all(
            color: isSelected ? const Color(0xFF00BCD4) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00BCD4) : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CustomRepeatDialog extends StatefulWidget {
  final List<int> initialDays;

  const _CustomRepeatDialog({required this.initialDays});

  @override
  State<_CustomRepeatDialog> createState() => _CustomRepeatDialogState();
}

class _CustomRepeatDialogState extends State<_CustomRepeatDialog> {
  late List<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = List.from(widget.initialDays);
  }

  final List<String> _dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Days'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(7, (index) {
          final day = index + 1; // Monday = 1, Sunday = 7
          final isSelected = _selectedDays.contains(day);
          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedDays.remove(day);
                } else {
                  _selectedDays.add(day);
                }
              });
            },
            child: Container(
              width: 60,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00BCD4) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _dayNames[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedDays),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

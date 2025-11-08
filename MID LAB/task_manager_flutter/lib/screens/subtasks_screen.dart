import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/subtask.dart';

class SubtasksScreen extends StatefulWidget {
  final int taskId;

  const SubtasksScreen({super.key, required this.taskId});

  @override
  State<SubtasksScreen> createState() => _SubtasksScreenState();
}

class _SubtasksScreenState extends State<SubtasksScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _controller = TextEditingController();
  List<Subtask> _subtasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubtasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSubtasks() async {
    setState(() => _isLoading = true);
    final subtasks = await _dbHelper.getSubtasksForTask(widget.taskId);
    setState(() {
      _subtasks = subtasks;
      _isLoading = false;
    });
  }

  Future<void> _addSubtask() async {
    if (_controller.text.trim().isEmpty) return;

    final subtask = Subtask(
      taskId: widget.taskId,
      title: _controller.text.trim(),
      createdAt: DateTime.now(),
    );

    await _dbHelper.insertSubtask(subtask);
    _controller.clear();
    _loadSubtasks();
  }

  Future<void> _toggleSubtask(Subtask subtask) async {
    final updated = subtask.copyWith(isCompleted: !subtask.isCompleted);
    await _dbHelper.updateSubtask(updated);
    _loadSubtasks();
  }

  Future<void> _deleteSubtask(int id) async {
    await _dbHelper.deleteSubtask(id);
    _loadSubtasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Subtasks'),
      ),
      body: Column(
        children: [
          // Add subtask input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a subtask',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Subtasks list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _subtasks.isEmpty
                    ? Center(
                        child: Text(
                          'No subtasks yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _subtasks.length,
                        itemBuilder: (context, index) {
                          final subtask = _subtasks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Checkbox(
                                value: subtask.isCompleted,
                                onChanged: (_) => _toggleSubtask(subtask),
                                activeColor: const Color(0xFF00BCD4),
                              ),
                              title: Text(
                                subtask.title,
                                style: TextStyle(
                                  decoration: subtask.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: subtask.isCompleted
                                      ? Colors.grey
                                      : null,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteSubtask(subtask.id!),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

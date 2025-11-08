import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/subtask.dart';

// Import TaskPriority enum

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        dueTime TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        repeatType TEXT NOT NULL DEFAULT 'none',
        repeatDays TEXT,
        notificationMinutesBefore INTEGER NOT NULL DEFAULT 15,
        createdAt TEXT NOT NULL,
        completedAt TEXT,
        priority TEXT NOT NULL DEFAULT 'medium',
        category TEXT
      )
    ''');

    // Subtasks table
    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add priority and category columns
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN priority TEXT NOT NULL DEFAULT \'medium\'');
      } catch (e) {
        // Column might already exist
      }
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN category TEXT');
      } catch (e) {
        // Column might already exist
      }
    }
  }

  // Task CRUD operations
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'dueDate ASC, dueTime ASC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));
    final maps = await db.query(
      'tasks',
      where: "dueDate >= ? AND dueDate < ? AND isCompleted = 0",
      whereArgs: [dateStart.toIso8601String(), dateEnd.toIso8601String()],
      orderBy: 'dueTime ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [1],
      orderBy: 'completedAt DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getRepeatedTasks() async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'repeatType != ? AND isCompleted = ?',
      whereArgs: ['none', 0],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> searchTasks(String query) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'dueDate ASC, dueTime ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final db = await database;
    final priorityStr = priority.toString().split('.').last;
    final maps = await db.query(
      'tasks',
      where: 'priority = ? AND isCompleted = ?',
      whereArgs: [priorityStr, 0],
      orderBy: 'dueDate ASC, dueTime ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'category = ? AND isCompleted = ?',
      whereArgs: [category, 0],
      orderBy: 'dueDate ASC, dueTime ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<String>> getAllCategories() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT category FROM tasks WHERE category IS NOT NULL AND category != \'\'',
    );
    return maps.map((map) => map['category'] as String).toList();
  }

  Future<Map<String, dynamic>> getTaskStatistics() async {
    final db = await database;
    final allTasks = await db.query('tasks');
    final totalTasks = allTasks.length;
    final completedTasks = allTasks.where((t) => (t['isCompleted'] as int) == 1).length;
    final pendingTasks = totalTasks - completedTasks;
    
    final highPriority = allTasks.where((t) => 
      t['priority'] == 'high' && (t['isCompleted'] as int) == 0
    ).length;
    
    final today = DateTime.now();
    final todayTasks = allTasks.where((t) {
      final dueDate = DateTime.parse(t['dueDate'] as String);
      return dueDate.year == today.year && 
             dueDate.month == today.month && 
             dueDate.day == today.day &&
             (t['isCompleted'] as int) == 0;
    }).length;
    
    final repeatedTasks = allTasks.where((t) => 
      t['repeatType'] != 'none' && (t['isCompleted'] as int) == 0
    ).length;
    
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'highPriorityTasks': highPriority,
      'todayTasks': todayTasks,
      'repeatedTasks': repeatedTasks,
      'completionRate': totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0,
    };
  }

  Future<Task?> getTask(int id) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    // Delete subtasks first (CASCADE should handle this, but being explicit)
    await db.delete('subtasks', where: 'taskId = ?', whereArgs: [id]);
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Subtask CRUD operations
  Future<int> insertSubtask(Subtask subtask) async {
    final db = await database;
    return await db.insert('subtasks', subtask.toMap());
  }

  Future<List<Subtask>> getSubtasksForTask(int taskId) async {
    final db = await database;
    final maps = await db.query(
      'subtasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => Subtask.fromMap(map)).toList();
  }

  Future<int> updateSubtask(Subtask subtask) async {
    final db = await database;
    return await db.update(
      'subtasks',
      subtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  Future<int> deleteSubtask(int id) async {
    final db = await database;
    return await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

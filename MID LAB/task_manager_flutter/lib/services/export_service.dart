import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../database/database_helper.dart';

class ExportService {
  static final ExportService instance = ExportService._init();
  ExportService._init();

  Future<String> exportToCSV(List<Task> tasks, DatabaseHelper dbHelper) async {
    final csvData = <List<dynamic>>[];
    
    // Header
    csvData.add([
      'Title',
      'Description',
      'Due Date',
      'Due Time',
      'Status',
      'Repeat Type',
      'Created At',
      'Completed At',
      'Subtasks',
    ]);

    // Data rows
    for (final task in tasks) {
      final subtasks = await dbHelper.getSubtasksForTask(task.id!);
      final subtasksText = subtasks.map((s) => s.title).join('; ');
      
      csvData.add([
        task.title,
        task.description,
        task.dueDate.toIso8601String(),
        task.dueTime ?? '',
        task.isCompleted ? 'Completed' : 'Pending',
        task.repeatType.toString().split('.').last,
        task.createdAt.toIso8601String(),
        task.completedAt?.toIso8601String() ?? '',
        subtasksText,
      ]);
    }

    final csvString = const ListToCsvConverter().convert(csvData);
    return csvString;
  }

  Future<File> exportToPDF(List<Task> tasks, DatabaseHelper dbHelper) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Build task sections synchronously (fetch subtasks first)
    final taskWidgets = <pw.Widget>[];
    for (final task in tasks) {
      final subtasks = await dbHelper.getSubtasksForTask(task.id!);
      taskWidgets.add(_buildTaskPDFSection(task, subtasks));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'TaskFlow - Task Export',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Exported on: ${now.toString().split('.').first}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            ...taskWidgets,
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tasks_export_${now.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildTaskPDFSection(Task task, List<Subtask> subtasks) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            task.title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            task.description,
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Due: ${task.dueDate.toString().split(' ')[0]} ${task.dueTime ?? ''}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Status: ${task.isCompleted ? 'Completed' : 'Pending'}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          if (subtasks.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              'Subtasks:',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            ...subtasks.map((s) => pw.Text(
              '  • ${s.title} ${s.isCompleted ? "(✓)" : ""}',
              style: const pw.TextStyle(fontSize: 10),
            )),
          ],
        ],
      ),
    );
  }

  Future<void> shareCSV(List<Task> tasks, DatabaseHelper dbHelper) async {
    final csvString = await exportToCSV(tasks, dbHelper);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tasks_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);
    
    final result = await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'TaskFlow Tasks Export',
    );
  }

  Future<void> sharePDF(List<Task> tasks, DatabaseHelper dbHelper) async {
    final file = await exportToPDF(tasks, dbHelper);
    final result = await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'TaskFlow Tasks Export',
    );
  }
}

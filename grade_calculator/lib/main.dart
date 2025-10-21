// lib/main.dart
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const GradePointApp());

class GradePointApp extends StatelessWidget {
  const GradePointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GradePoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        fontFamily: 'Poppins',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  final _pages = const [
    DashboardPage(),
    GPAPage(),
    CGPAPage(),
    PlannerPage(),
    ConverterPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'GPA'),
          NavigationDestination(icon: Icon(Icons.show_chart_outlined), label: 'CGPA'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'Planner'),
          NavigationDestination(icon: Icon(Icons.percent_outlined), label: 'Convert'),
        ],
      ),
    );
  }
}

/// ---------------- DASHBOARD ----------------
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text('GradePoint', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Your academic companion — GPA, CGPA, Planner & Converter', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _dashboardCard(context, Icons.calculate, 'GPA', 'Semester GPA calculator', () => _openPage(context, const GPAPage())),
                  _dashboardCard(context, Icons.show_chart, 'CGPA', 'Combine multiple semesters', () => _openPage(context, const CGPAPage())),
                  _dashboardCard(context, Icons.flag, 'Planner', 'Plan to reach target CGPA', () => _openPage(context, const PlannerPage())),
                  _dashboardCard(context, Icons.sync_alt, 'Converter', 'CGPA → Percentage', () => _openPage(context, const ConverterPage())),
                ],
              ),
              const SizedBox(height: 28),
              // small legend / quick tips
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Quick tips', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('- Add subjects with credit hours and marks. GPA uses weighted average (grade-point * credits).'),
                    const SizedBox(height: 6),
                    const Text('- CGPA calculator combines previous CGPA and current semester GPA.'),
                  ]),
                ),
              ),
              SizedBox(height: mq.size.height * 0.15),
              const Center(child: Text('MADE BY SYED ZAIN BUKHARI', style: TextStyle(color: Colors.white70))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    final w = MediaQuery.of(context).size.width;
    final cardW = (w / 2) - 28;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardW < 220 ? w - 36 : cardW,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13))])),
        ]),
      ),
    );
  }

  void _openPage(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

/// ---------------- GPA PAGE ----------------
/// Full GPA builder: subject name, semester name, credit hours, marks -> letter grade & grade point
class GPAPage extends StatefulWidget {
  const GPAPage({super.key});
  @override
  State<GPAPage> createState() => _GPAPageState();
}

class _GPAPageState extends State<GPAPage> {
  final TextEditingController semesterCtrl = TextEditingController();
  final List<_SubjectRow> rows = [];

  double _gpa = 0.0;
  List<Map<String, String>> _summary = [];

  @override
  void initState() {
    super.initState();
    rows.add(_SubjectRow()); // start with one row
  }

  void _addRow() {
    setState(() => rows.add(_SubjectRow()));
  }

  void _removeRow(int i) {
    if (rows.length <= 1) return;
    setState(() => rows.removeAt(i));
  }

  // Grade scale - tweak numbers here if your university uses different mapping
  // This mapping is used for grade text and grade-point (4.0 scale).
  Map<String, dynamic> gradeFromMarks(double m) {

    if (m >= 85) return {'grade': 'A', 'point': 4.0};
    if (m >= 80) return {'grade': 'A-', 'point': 3.66};
    if (m >= 75) return {'grade': 'B+', 'point': 3.33};
    if (m >= 71) return {'grade': 'B', 'point': 3.0};
    if (m >= 68) return {'grade': 'B-', 'point': 2.66};
    if (m >= 64) return {'grade': 'C+', 'point': 2.33};
    if (m >= 61) return {'grade': 'C', 'point': 2.0};
    if (m >= 58) return {'grade': 'C-', 'point': 1.66};
    if (m >= 54) return {'grade': 'D+', 'point': 1.3}; // D = 50-54
    if (m >= 50) return {'grade': 'D', 'point': 1.0}; // D = 50-54

    return {'grade': 'F', 'point': 0.0};
  }

  void _calculate() {
    double totalPoints = 0.0;
    double totalCredits = 0.0;
    final tempSummary = <Map<String, String>>[];

    for (var r in rows) {
      final name = r.nameCtrl.text.trim().isEmpty ? 'Untitled' : r.nameCtrl.text.trim();
      final credits = double.tryParse(r.creditCtrl.text) ?? 0.0;
      final marks = double.tryParse(r.marksCtrl.text) ?? 0.0;
      final g = gradeFromMarks(marks);
      final gp = (g['point'] as double);
      totalPoints += gp * credits;
      totalCredits += credits;
      tempSummary.add({'subject': name, 'marks': marks.toStringAsFixed(1), 'grade': g['grade'], 'gp': gp.toStringAsFixed(2), 'credits': credits.toStringAsFixed(1)});
    }

    setState(() {
      _gpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;
      _summary = tempSummary;
    });
    // scroll to results (if desired) - not implemented here to keep it simple
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('GPA Calculator'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width < 700 ? width : 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // header card
                _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Semester', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(controller: semesterCtrl, decoration: _inputDecoration('Semester name (e.g., Fall 2025)')),
                ])),
                const SizedBox(height: 14),

                // subject rows
                ...rows.asMap().entries.map((e) {
                  final i = e.key;
                  final row = e.value;
                  return _buildSubjectCard(row, i);
                }),

                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Subject'),
                      onPressed: _addRow,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate GPA'),
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                  ),
                ]),

                const SizedBox(height: 16),

                // results
                if (_summary.isNotEmpty)
                  _glassCard(child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Semester: ${semesterCtrl.text.isEmpty ? 'N/A' : semesterCtrl.text}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('GPA: ${_gpa.toStringAsFixed(3)} / 4.00', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.indigo)),
                    ]),
                    const SizedBox(height: 12),
                    const Divider(),
                    Column(children: _summary.map((s) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(s['subject'] ?? ''),
                        subtitle: Text('Marks: ${s['marks']} • Grade: ${s['grade']} • GP: ${s['gp']} • Cr: ${s['credits']}'),
                      );
                    }).toList())
                  ])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(_SubjectRow row, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: TextField(controller: row.nameCtrl, decoration: _inputDecoration('Subject name'))),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _removeRow(index)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: row.creditCtrl, decoration: _inputDecoration('Credits'), keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: row.marksCtrl, decoration: _inputDecoration('Marks (0-100)'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: row.marksCtrl,
              builder: (context, _, __) {
                final marks = double.tryParse(row.marksCtrl.text) ?? 0.0;
                final g = gradeFromMarks(marks);
                return Text('Grade: ${g['grade']}    Grade Point: ${ (g['point'] as double).toStringAsFixed(2) }', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(14)),
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));
}

/// helper class for rows
class _SubjectRow {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController creditCtrl = TextEditingController(text: '3');
  final TextEditingController marksCtrl = TextEditingController();
}

/// ---------------- CGPA PAGE ----------------
class CGPAPage extends StatefulWidget {
  const CGPAPage({super.key});
  @override
  State<CGPAPage> createState() => _CGPAPageState();
}

class _CGPAPageState extends State<CGPAPage> {
  final List<_SemesterRow> semesters = [ _SemesterRow() ];
  double _cgpa = 0.0;

  void _addSemester() => setState(() => semesters.add(_SemesterRow()));
  void _removeSemester(int i) { if (semesters.length>1) setState(()=>semesters.removeAt(i)); }

  void _calculateCGPA() {
    double totalPoints = 0, totalCredits = 0;
    for (var s in semesters) {
      final credits = double.tryParse(s.creditsCtrl.text) ?? 0;
      final gpa = double.tryParse(s.gpaCtrl.text) ?? 0;
      totalCredits += credits;
      totalPoints += gpa * credits;
    }
    setState(() { _cgpa = totalCredits>0 ? totalPoints/totalCredits : 0.0; });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('CGPA Calculator'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: w < 700 ? w : 700),
            child: Column(
              children: [
                ...semesters.asMap().entries.map((e) {
                  final i = e.key; final s = e.value;
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Expanded(child: TextField(controller: s.nameCtrl, decoration: const InputDecoration(labelText: 'Semester (optional)'))),
                        const SizedBox(width: 8),
                        SizedBox(width: 120, child: TextField(controller: s.creditsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Credits'))),
                        const SizedBox(width: 8),
                        SizedBox(width: 120, child: TextField(controller: s.gpaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'GPA'))),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: ()=>_removeSemester(i)),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton.icon(onPressed: _addSemester, icon: const Icon(Icons.add), label: const Text('Add Semester')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(onPressed: _calculateCGPA, icon: const Icon(Icons.calculate), label: const Text('Calc CGPA'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700)),
                ]),
                const SizedBox(height: 16),
                Card(
                  child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [ Text('CGPA: ${_cgpa.toStringAsFixed(3)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)) ])),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SemesterRow {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController creditsCtrl = TextEditingController();
  final TextEditingController gpaCtrl = TextEditingController();
}

/// ---------------- PLANNER PAGE ----------------
class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});
  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final TextEditingController currentCgpaCtrl = TextEditingController();
  final TextEditingController completedCreditsCtrl = TextEditingController();
  final TextEditingController remainingCreditsCtrl = TextEditingController();
  final TextEditingController targetCgpaCtrl = TextEditingController();

  double? requiredGPA;

  void _plan() {
    final currentCgpa = double.tryParse(currentCgpaCtrl.text) ?? 0.0;
    final completed = double.tryParse(completedCreditsCtrl.text) ?? 0.0;
    final remaining = double.tryParse(remainingCreditsCtrl.text) ?? 0.0;
    final target = double.tryParse(targetCgpaCtrl.text) ?? 0.0;
    final totalCredits = completed + remaining;
    if (remaining <= 0) { setState(()=> requiredGPA = null); return; }
    final neededPoints = target * totalCredits - currentCgpa * completed;
    setState(()=> requiredGPA = neededPoints / remaining);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('CGPA Planner'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: w < 700 ? w : 700),
            child: Column(children: [
              Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
                TextField(controller: currentCgpaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Current CGPA')),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: completedCreditsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Completed Credits'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: remainingCreditsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Remaining Credits'))),
                ]),
                const SizedBox(height: 8),
                TextField(controller: targetCgpaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target CGPA')),
                const SizedBox(height: 12),
                ElevatedButton.icon(onPressed: _plan, icon: const Icon(Icons.flag), label: const Text('Calculate Required GPA')),
                const SizedBox(height: 8),
                if (requiredGPA != null)
                  Text('Required avg GPA for remaining credits: ${requiredGPA!.isFinite ? requiredGPA!.toStringAsFixed(3) : '—'}', style: const TextStyle(fontWeight: FontWeight.w700))
              ])))
            ]),
          ),
        ),
      ),
    );
  }
}

/// ---------------- CONVERTER PAGE ----------------
class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});
  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController cgpaCtrl = TextEditingController();
  double? percent;
  String scale = '4.0';
  final TextEditingController customScaleCtrl = TextEditingController(text: '4.0');

  void _convert() {
    final c = double.tryParse(cgpaCtrl.text) ?? 0.0;
    final s = scale == 'custom' ? (double.tryParse(customScaleCtrl.text) ?? 4.0) : double.tryParse(scale) ?? 4.0;
    setState(()=> percent = s>0 ? (c/s)*100 : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CGPA → % Converter'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
              TextField(controller: cgpaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Enter CGPA')),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(value: scale, items: const [DropdownMenuItem(value: '4.0', child: Text('Scale 4.0')), DropdownMenuItem(value: '5.0', child: Text('Scale 5.0')), DropdownMenuItem(value: 'custom', child: Text('Custom'))], onChanged: (v)=> setState(()=> scale = v ?? '4.0'))),
                const SizedBox(width: 10),
                if (scale == 'custom') Expanded(child: TextField(controller: customScaleCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Custom scale'))),
              ]),
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: _convert, icon: const Icon(Icons.sync_alt), label: const Text('Convert')),
              const SizedBox(height: 12),
              if (percent != null) Text('Percentage: ${percent!.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))
            ])))
          ]),
        ),
      ),
    );
  }
}

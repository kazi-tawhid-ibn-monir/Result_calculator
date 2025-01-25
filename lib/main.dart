import 'package:flutter/material.dart';

void main() {
  runApp(StudentMarksApp());
}

class StudentMarksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Marks Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> students = [];

  void _addStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudentInputPage()),
    );

    if (result != null) {
      setState(() {
        students.add(result);
      });
    }
  }

  void _viewRankings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RankingPage(students: students)),
    );

    if (result == true) {
      setState(() {
        students.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Management')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _addStudent,
              child: Text('Add Student'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: students.isNotEmpty ? _viewRankings : null,
              child: Text('View Rankings'),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentInputPage extends StatefulWidget {
  @override
  _StudentInputPageState createState() => _StudentInputPageState();
}

class _StudentInputPageState extends State<StudentInputPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final List<TextEditingController> _subjectControllers =
  List.generate(10, (index) => TextEditingController());

  final List<String> _subjects = [
    'Bangla', 'English', 'Math', 'Science', 'History',
    'Islam', 'Biology', 'Health', 'IT', 'Culture'
  ];

  void _calculateMarks(BuildContext context) {
    Map<String, dynamic> studentDetails = {
      'name': _nameController.text,
      'roll': _rollController.text,
      'class': _classController.text,
      'subjects': {}
    };

    double totalMarks = 0;

    for (int i = 0; i < _subjects.length; i++) {
      double mark = double.tryParse(_subjectControllers[i].text) ?? 0;
      double processedMark = mark * 0.7;
      int additionalMark = 0;

      if (processedMark >= 35 && processedMark <= 79) {
        additionalMark = 25;
      } else if (processedMark >= 20 && processedMark < 35) {
        additionalMark = 20;
      } else if (processedMark >= 1 && processedMark < 20) {
        additionalMark = 15;
      }

      processedMark += additionalMark;
      totalMarks += processedMark;
      studentDetails['subjects'][_subjects[i]] = {
        'finalMark': processedMark,
        'grade': _assignGrade(processedMark),
      };
    }

    studentDetails['totalMarks'] = totalMarks;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          studentDetails: studentDetails,
          onComplete: () {
            _clearControllers();
          },
        ),
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _rollController.clear();
    _classController.clear();
    for (var controller in _subjectControllers) {
      controller.clear();
    }
  }

  String _assignGrade(double mark) {
    if (mark >= 80) return 'A+';
    if (mark >= 70) return 'A';
    if (mark >= 60) return 'A-';
    if (mark >= 50) return 'B';
    if (mark >= 40) return 'C';
    if (mark >= 33) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Student Name'),
            ),
            TextField(
              controller: _rollController,
              decoration: InputDecoration(labelText: 'Roll Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _classController,
              decoration: InputDecoration(labelText: 'Class'),
            ),
            SizedBox(height: 20),
            Text('Subject Marks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...List.generate(_subjects.length, (index) {
              return TextField(
                controller: _subjectControllers[index],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter marks for ${_subjects[index]}',
                ),
              );
            }),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _calculateMarks(context),
              child: Text('Calculate Marks'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final Map<String, dynamic> studentDetails;
  final VoidCallback onComplete;

  ResultsPage({required this.studentDetails, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: studentDetails.entries.map((entry) {
                  if (entry.key == 'totalMarks') {
                    return Text(
                      'Total Marks: ${entry.value.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  } else if (entry.key != 'subjects') {
                    return ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value.toString()),
                    );
                  } else {
                    final subjects = entry.value as Map<String, dynamic>;
                    return Column(
                      children: subjects.entries.map((subEntry) {
                        final data = subEntry.value as Map<String, dynamic>;
                        return ListTile(
                          title: Text(subEntry.key),
                          subtitle: Text('Mark: ${data['finalMark'].toStringAsFixed(2)}, Grade: ${data['grade']}'),
                        );
                      }).toList(),
                    );
                  }
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onComplete();
                Navigator.pop(context, studentDetails);
              },
              child: Text('Add Another Student'),
            ),
          ],
        ),
      ),
    );
  }
}

class RankingPage extends StatefulWidget {
  final List<Map<String, dynamic>> students;

  RankingPage({required this.students});

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Rankings'),
          content: Text('Are you sure you want to clear all student records?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Clear'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rankedStudents = List<Map<String, dynamic>>.from(widget.students)
      ..sort((a, b) => b['totalMarks'].compareTo(a['totalMarks']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Rankings'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () => _showClearConfirmationDialog(context),
            tooltip: 'Clear All Records',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: rankedStudents.length,
        itemBuilder: (context, index) {
          final student = rankedStudents[index];
          return ListTile(
            title: Text('${student['name']} (Roll: ${student['roll']})'),
            subtitle: Text('Total Marks: ${student['totalMarks'].toStringAsFixed(2)}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentDetailsPage(student: student),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StudentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> student;

  StudentDetailsPage({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${student['name']}', style: TextStyle(fontSize: 18)),
            Text('Roll: ${student['roll']}', style: TextStyle(fontSize: 18)),
            Text('Class: ${student['class']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Total Marks: ${student['totalMarks'].toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Subject-wise Marks:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView(
                children: student['subjects'].entries.map<Widget>((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    trailing: Text(
                      '${entry.value['finalMark'].toStringAsFixed(2)} (${entry.value['grade']})',
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
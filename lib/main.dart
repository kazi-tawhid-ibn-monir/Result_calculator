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
  final List<TextEditingController> _controllers =
  List.generate(10, (index) => TextEditingController());
  final List<String> _subjects = [
    'Bangla', 'English', 'Math', 'Science', 'History',
    'Islam', 'Biology', 'Health', 'IT', 'Culture'
  ];

  List<Map<String, dynamic>> students = [];

  void _calculateMarks() {
    double totalMarks = 0;
    Map<String, dynamic> studentDetails = {};

    for (int i = 0; i < _subjects.length; i++) {
      double mark = double.tryParse(_controllers[i].text) ?? 0;
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
      studentDetails[_subjects[i]] = {
        'finalMark': processedMark,
        'grade': _assignGrade(processedMark),
      };
    }

    studentDetails['totalMarks'] = totalMarks;
    students.add(studentDetails);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          studentDetails: studentDetails,
          onComplete: () {
            setState(() {
              for (var controller in _controllers) {
                controller.clear();
              }
            });
          },
        ),
      ),
    );
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

  void _viewRankings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RankingPage(students: students),
      ),
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
      appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('Student Marks Input',style: TextStyle(fontSize:25,fontWeight: FontWeight.bold,color: Colors.white),)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  return TextField(
                    controller: _controllers[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter marks for ${_subjects[index]}',
                      labelStyle: TextStyle(fontSize: 15,color: Colors.black54.withOpacity(0.6),),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculateMarks,
              child: Text('Calculate Marks'),
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

class ResultsPage extends StatelessWidget {
  final Map<String, dynamic> studentDetails;
  final VoidCallback onComplete;

  ResultsPage({required this.studentDetails, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('Results')),
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
                  } else {
                    final data = entry.value as Map<String, dynamic>;
                    return ListTile(
                      title: Text(entry.key),
                      subtitle: Text('Mark: ${data['finalMark'].toStringAsFixed(2)}, Grade: ${data['grade']}'),
                    );
                  }
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onComplete();
                Navigator.pop(context);
              },
              child: Text('Add Another Student'),
            ),
          ],
        ),
      ),
    );
  }
}

class RankingPage extends StatelessWidget {
  final List<Map<String, dynamic>> students;

  RankingPage({required this.students});

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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
    final rankedStudents = List<Map<String, dynamic>>.from(students)
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: rankedStudents.length,
          itemBuilder: (context, index) {
            final student = rankedStudents[index];
            return ListTile(
              title: Text('Student ${index + 1}'),
              subtitle: Text('Total Marks: ${student['totalMarks'].toStringAsFixed(2)}'),
            );
          },
        ),
      ),
    );
  }
}
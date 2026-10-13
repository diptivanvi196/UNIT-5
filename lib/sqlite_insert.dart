import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MaterialApp(home: SqliteInsertApp()));
}

class SqliteInsertApp extends StatefulWidget {
  const SqliteInsertApp({super.key});

  @override
  State<SqliteInsertApp> createState() => _SqliteInsertAppState();
}

class _SqliteInsertAppState extends State<SqliteInsertApp> {
  Database? _db;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _courseController = TextEditingController();
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'students_insert.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, course TEXT)',
        );
      },
    );
    _loadStudents();
  }

  Future<void> _insertStudent() async {
    if (_db == null || _nameController.text.isEmpty) return;
    await _db!.insert('students', {
      'name': _nameController.text,
      'age': int.tryParse(_ageController.text) ?? 0,
      'course': _courseController.text,
    });
    _nameController.clear();
    _ageController.clear();
    _courseController.clear();
    _loadStudents();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New student record inserted into SQLite!')),
    );
  }

  Future<void> _loadStudents() async {
    if (_db == null) return;
    final data = await _db!.query('students');
    setState(() {
      _students = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite - Insert Record'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Insert New Student Record',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Student Age',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _insertStudent,
              icon: const Icon(Icons.add_circle),
              label: const Text('Insert Record'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Students Table Contents:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _students.isEmpty
                ? const Text('No student records found.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final item = _students[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            child: Text('${item['id']}'),
                          ),
                          title: Text('${item['name']} (Age: ${item['age']})'),
                          subtitle: Text('Course: ${item['course']}'),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

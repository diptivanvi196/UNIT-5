import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MaterialApp(home: SqliteDisplayApp()));
}

class SqliteDisplayApp extends StatefulWidget {
  const SqliteDisplayApp({super.key});

  @override
  State<SqliteDisplayApp> createState() => _SqliteDisplayAppState();
}

class _SqliteDisplayAppState extends State<SqliteDisplayApp> {
  Database? _db;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'students_display.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, course TEXT)',
        );
        await db.insert('students', {'name': 'Alice Johnson', 'course': 'Computer Science'});
        await db.insert('students', {'name': 'Bob Smith', 'course': 'Information Technology'});
        await db.insert('students', {'name': 'Charlie Brown', 'course': 'Data Science'});
        await db.insert('students', {'name': 'Diana Prince', 'course': 'Software Engineering'});
      },
    );
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    if (_db == null) return;
    final list = await _db!.query('students');
    setState(() {
      _students = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite - Display in ListView'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Displaying all SQLite Records using ListView:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _students.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              child: Text('${student['id']}'),
                            ),
                            title: Text(
                              student['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Course: ${student['course']}'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

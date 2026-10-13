import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MaterialApp(home: SqliteDeleteApp()));
}

class SqliteDeleteApp extends StatefulWidget {
  const SqliteDeleteApp({super.key});

  @override
  State<SqliteDeleteApp> createState() => _SqliteDeleteAppState();
}

class _SqliteDeleteAppState extends State<SqliteDeleteApp> {
  Database? _db;
  List<Map<String, dynamic>> _students = [];
  final _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'students_delete.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, course TEXT)',
        );
        await db.insert('students', {'name': 'David Miller', 'course': 'Java'});
        await db.insert('students', {'name': 'Emma Watson', 'course': 'Python'});
        await db.insert('students', {'name': 'Frank Castle', 'course': 'C++'});
      },
    );
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    if (_db == null) return;
    final list = await _db!.query('students');
    setState(() {
      _students = list;
    });
  }

  Future<void> _deleteRecordById(int id) async {
    if (_db == null) return;
    await _db!.delete('students', where: 'id = ?', whereArgs: [id]);
    _loadStudents();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted record with ID: $id')),
    );
  }

  Future<void> _deleteFromField() async {
    final id = int.tryParse(_idController.text);
    if (id != null) {
      await _deleteRecordById(id);
      _idController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite - Delete Record'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Delete Record by ID',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter Record ID to Delete',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.delete_forever),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _deleteFromField,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Record'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Current Records in Table:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _students.isEmpty
                ? const Text('No records remaining in SQLite table.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final item = _students[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            child: Text('${item['id']}'),
                          ),
                          title: Text(item['name']),
                          subtitle: Text('Course: ${item['course']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRecordById(item['id']),
                          ),
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

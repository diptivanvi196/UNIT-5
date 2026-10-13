import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MaterialApp(home: SqliteUpdateApp()));
}

class SqliteUpdateApp extends StatefulWidget {
  const SqliteUpdateApp({super.key});

  @override
  State<SqliteUpdateApp> createState() => _SqliteUpdateAppState();
}

class _SqliteUpdateAppState extends State<SqliteUpdateApp> {
  Database? _db;
  List<Map<String, dynamic>> _students = [];

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'students_update.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, course TEXT)',
        );
        await db.insert('students', {'name': 'John Doe', 'course': 'Flutter'});
        await db.insert('students', {'name': 'Jane Smith', 'course': 'Android'});
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

  Future<void> _updateRecord() async {
    final id = int.tryParse(_idController.text);
    if (_db == null || id == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid ID and Name.')),
      );
      return;
    }

    await _db!.update(
      'students',
      {
        'name': _nameController.text,
        'course': _courseController.text,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    _idController.clear();
    _nameController.clear();
    _courseController.clear();
    _loadStudents();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Record with ID $id updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite - Update Record'),
        backgroundColor: Colors.blue,
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
                      'Update Record by ID',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter Record ID to Update',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'New Student Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _courseController,
                      decoration: const InputDecoration(
                        labelText: 'New Course Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _updateRecord,
                      icon: const Icon(Icons.edit),
                      label: const Text('Update Record'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Current Records in Database:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _students.isEmpty
                ? const Text('No records in table.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final item = _students[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            child: Text('${item['id']}'),
                          ),
                          title: Text(item['name']),
                          subtitle: Text('Course: ${item['course']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _idController.text = '${item['id']}';
                              _nameController.text = item['name'];
                              _courseController.text = item['course'];
                            },
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

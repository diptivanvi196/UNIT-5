import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pref_username.dart';
import 'pref_dark_mode.dart';
import 'sqlite_products.dart';
import 'sqlite_insert.dart';
import 'sqlite_display.dart';
import 'sqlite_update.dart';
import 'sqlite_delete.dart';
import 'hive_todo.dart';
import 'hive_user.dart';
import 'file_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Practical Tasks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final List<Map<String, dynamic>> tasks = const [
    {
      'title': '1. Shared Preferences - Username',
      'subtitle': 'Save username & display after app restart',
      'icon': Icons.account_circle,
      'color': Colors.indigo,
      'widget': PrefUsernameApp(),
    },
    {
      'title': '2. Shared Preferences - Dark Mode',
      'subtitle': 'Switch to save & load Dark Mode setting',
      'icon': Icons.dark_mode,
      'color': Colors.amber,
      'widget': PrefDarkModeApp(),
    },
    {
      'title': '3. SQLite - Products Table',
      'subtitle': 'Create products table with id, name, price',
      'icon': Icons.shopping_cart,
      'color': Colors.teal,
      'widget': SqliteProductsApp(),
    },
    {
      'title': '4. SQLite - Insert Student Record',
      'subtitle': 'Insert new record into students table',
      'icon': Icons.person_add,
      'color': Colors.deepOrange,
      'widget': SqliteInsertApp(),
    },
    {
      'title': '5. SQLite - Display in ListView',
      'subtitle': 'Display all records from table using ListView',
      'icon': Icons.list_alt,
      'color': Colors.purple,
      'widget': SqliteDisplayApp(),
    },
    {
      'title': '6. SQLite - Update Record by ID',
      'subtitle': 'Update specific record based on its ID',
      'icon': Icons.edit,
      'color': Colors.blue,
      'widget': SqliteUpdateApp(),
    },
    {
      'title': '7. SQLite - Delete Record by ID',
      'subtitle': 'Delete specific record based on its ID',
      'icon': Icons.delete,
      'color': Colors.red,
      'widget': SqliteDeleteApp(),
    },
    {
      'title': '8. Hive - Simple To-Do Note',
      'subtitle': 'Use Hive to save and display To-Do note',
      'icon': Icons.check_box,
      'color': Colors.amber,
      'widget': HiveTodoApp(),
    },
    {
      'title': '9. Hive - User Name & Age',
      'subtitle': 'Store and display user name and age together',
      'icon': Icons.badge,
      'color': Colors.green,
      'widget': HiveUserApp(),
    },
    {
      'title': '10. File Storage (path_provider)',
      'subtitle': 'Read & write text to local file',
      'icon': Icons.insert_drive_file,
      'color': Colors.brown,
      'widget': FileStorageApp(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Practical Tasks'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: task['color'] as Color,
                foregroundColor: Colors.white,
                child: Icon(task['icon'] as IconData),
              ),
              title: Text(
                task['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(task['subtitle'] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => task['widget'] as Widget,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

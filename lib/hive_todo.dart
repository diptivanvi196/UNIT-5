import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('todoBox');
  runApp(const MaterialApp(home: HiveTodoApp()));
}

class HiveTodoApp extends StatefulWidget {
  const HiveTodoApp({super.key});

  @override
  State<HiveTodoApp> createState() => _HiveTodoAppState();
}

class _HiveTodoAppState extends State<HiveTodoApp> {
  Box? _todoBox;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen('todoBox')) {
      _todoBox = await Hive.openBox('todoBox');
    } else {
      _todoBox = Hive.box('todoBox');
    }
    setState(() {});
  }

  void _addTodo() {
    if (_controller.text.isNotEmpty && _todoBox != null) {
      _todoBox!.add(_controller.text);
      _controller.clear();
      setState(() {});
    }
  }

  void _deleteTodo(int index) {
    if (_todoBox != null) {
      _todoBox!.deleteAt(index);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive - Simple To-Do Note'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter To-Do Note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  ),
                  child: const Text('Add Note'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Saved To-Do Notes in Hive:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _todoBox == null || _todoBox!.isEmpty
                  ? const Center(child: Text('No notes saved yet.'))
                  : ValueListenableBuilder(
                      valueListenable: _todoBox!.listenable(),
                      builder: (context, Box box, _) {
                        return ListView.builder(
                          itemCount: box.length,
                          itemBuilder: (context, index) {
                            final note = box.getAt(index).toString();
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.note, color: Colors.amber),
                                title: Text(note),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTodo(index),
                                ),
                              ),
                            );
                          },
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

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  runApp(const MaterialApp(home: HiveUserApp()));
}

class HiveUserApp extends StatefulWidget {
  const HiveUserApp({super.key});

  @override
  State<HiveUserApp> createState() => _HiveUserAppState();
}

class _HiveUserAppState extends State<HiveUserApp> {
  Box? _userBox;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _displayName = 'Not Saved';
  String _displayAge = 'Not Saved';

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen('userBox')) {
      _userBox = await Hive.openBox('userBox');
    } else {
      _userBox = Hive.box('userBox');
    }
    _loadUserData();
  }

  void _loadUserData() {
    if (_userBox != null) {
      setState(() {
        _displayName = _userBox!.get('name', defaultValue: 'Not Saved');
        _displayAge = _userBox!.get('age', defaultValue: 'Not Saved').toString();
      });
    }
  }

  Future<void> _saveUserData() async {
    if (_userBox != null && _nameController.text.isNotEmpty) {
      await _userBox!.put('name', _nameController.text);
      await _userBox!.put('age', _ageController.text);
      _nameController.clear();
      _ageController.clear();
      _loadUserData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Age stored together in Hive!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive - Store Name & Age'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.green.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Stored User Details in Hive:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Name', style: TextStyle(color: Colors.grey)),
                            Text(
                              _displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Age', style: TextStyle(color: Colors.grey)),
                            Text(
                              _displayAge,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'User Age',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveUserData,
              icon: const Icon(Icons.save),
              label: const Text('Save Name & Age in Hive'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

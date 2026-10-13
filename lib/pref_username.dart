import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(home: PrefUsernameApp()));
}

class PrefUsernameApp extends StatefulWidget {
  const PrefUsernameApp({super.key});

  @override
  State<PrefUsernameApp> createState() => _PrefUsernameAppState();
}

class _PrefUsernameAppState extends State<PrefUsernameApp> {
  final TextEditingController _controller = TextEditingController();
  String _savedUsername = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUsername = prefs.getString('username') ?? 'No username saved';
    });
  }

  Future<void> _saveUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _controller.text);
    _controller.clear();
    _loadUsername();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Preferences - Username'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.indigo.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Saved Username:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _savedUsername,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveUsername,
              icon: const Icon(Icons.save),
              label: const Text('Save Username'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

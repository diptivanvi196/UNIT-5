import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PrefDarkModeApp());
}

class PrefDarkModeApp extends StatefulWidget {
  const PrefDarkModeApp({super.key});

  @override
  State<PrefDarkModeApp> createState() => _PrefDarkModeAppState();
}

class _PrefDarkModeAppState extends State<PrefDarkModeApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Shared Preferences - Dark Mode'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      size: 64,
                      color: _isDarkMode ? Colors.amber : Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isDarkMode ? 'Dark Mode Active' : 'Light Mode Active',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Enable Dark Mode'),
                      subtitle: const Text('Saves setting in Shared Preferences'),
                      value: _isDarkMode,
                      onChanged: _toggleDarkMode,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

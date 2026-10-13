import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(home: FileStorageApp()));
}

class FileStorageApp extends StatefulWidget {
  const FileStorageApp({super.key});

  @override
  State<FileStorageApp> createState() => _FileStorageAppState();
}

class _FileStorageAppState extends State<FileStorageApp> {
  final TextEditingController _controller = TextEditingController();
  String _fileContent = 'No data loaded';

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/local_data.txt');
  }

  Future<void> _writeToFile() async {
    if (_controller.text.isEmpty) return;
    final file = await _getFile();
    await file.writeAsString(_controller.text);
    _controller.clear();
    await _readFromFile();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text saved to local file!')),
    );
  }

  Future<void> _readFromFile() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        String content = await file.readAsString();
        setState(() {
          _fileContent = content.isEmpty ? 'File is empty' : content;
        });
      } else {
        setState(() {
          _fileContent = 'File does not exist yet.';
        });
      }
    } catch (e) {
      setState(() {
        _fileContent = 'Error reading file: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _readFromFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Storage (path_provider)'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.brown.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Content Read from Local File:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fileContent,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.brown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Enter text to write to file',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _writeToFile,
                    icon: const Icon(Icons.edit_document),
                    label: const Text('Write to File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _readFromFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Read File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

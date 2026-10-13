import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MaterialApp(home: SqliteProductsApp()));
}

class SqliteProductsApp extends StatefulWidget {
  const SqliteProductsApp({super.key});

  @override
  State<SqliteProductsApp> createState() => _SqliteProductsAppState();
}

class _SqliteProductsAppState extends State<SqliteProductsApp> {
  Database? _database;
  List<Map<String, dynamic>> _products = [];
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'products_db.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL
          )
        ''');
      },
    );
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    if (_database == null) return;
    final data = await _database!.query('products');
    setState(() {
      _products = data;
    });
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;
    await _database?.insert('products', {
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
    });
    _nameController.clear();
    _priceController.clear();
    _refreshProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added to SQLite table!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite - Products Table'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Product Price (₹)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addProduct,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Product to Database'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Products Table Records (id, name, price)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _products.isEmpty
                  ? const Center(child: Text('No products in SQLite database.'))
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final item = _products[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              child: Text('${item['id']}'),
                            ),
                            title: Text(item['name']),
                            trailing: Text(
                              '₹${item['price']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
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

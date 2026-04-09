import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data/db_helper.dart';
import 'services/AuthService.dart';
import 'screens/LoginScreen.dart';
import 'package:marketapp2/screens/SiparisFormScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/SepetScreen.dart';

void main() {
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const AuthCheck(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const AnaSayfa(title: 'AnaSayfa'),
      },
    );
  }
}

// Token kontrolü
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final AuthService _authService = AuthService();
  bool _loading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _authService.getToken();
    setState(() {
      _isLoggedIn = token != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _isLoggedIn
        ? const AnaSayfa(title: 'AnaSayfa')
        : const LoginScreen();
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key, required this.title});
  final String title;

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  List products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final res = await http.get(
      Uri.parse('http://192.168.0.18:5239/api/product'),
    );
    setState(() {
      products = json.decode(res.body)['\$values'];
      loading = false;
    });
  }

  void printDbPath() async {
    final path = await getDatabasesPath();
    print("DATABASE PATH: $path");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("MarketApp", style: TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SepetScreen()),
              );
            },
            child: Icon(Icons.shopping_cart, color: Colors.red),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(12),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.63,
              children: [
                for (var p in products)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['Name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${p['Price']} ₺',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () async {
                              printDbPath();
                              await DBHelper.insert({
                                'id': p['Id'],
                                'name': p['Name'],
                                'price': p['Price'],
                                'adet': 1,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${p['Name']} sepete eklendi'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: Size(double.infinity, 36),
                            ),
                            child: Text(
                              'Sepete Ekle',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data/db_helper.dart';
import 'services/AuthService.dart';
import 'screens/LoginScreen.dart';
import 'package:marketapp2/screens/SiparisFormScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

class SepetScreen extends StatefulWidget {
  const SepetScreen({super.key});

  @override
  State<SepetScreen> createState() => _SepetScreenState();
}

class _SepetScreenState extends State<SepetScreen> {
  List<Map<String, dynamic>> sepet = [];

  @override
  void initState() {
    super.initState();
    verileriYukle();
  }

  Future<void> verileriYukle() async {
    final data = await DBHelper.getAll();
    setState(() => sepet = data);
  }

  Future<void> adetGuncelle(int id, int yeniAdet) async {
    if (yeniAdet <= 0) {
      await DBHelper.delete(id);
    } else {
      await DBHelper.update(id, yeniAdet);
    }
    verileriYukle();
  }

  @override
  Widget build(BuildContext context) {
    double toplam = sepet.fold(0, (sum, p) => sum + (p['price'] * p['adet']));

    return Scaffold(
      appBar: AppBar(title: Text('Sepetim')),

      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  '${toplam.toStringAsFixed(2)} ₺',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: sepet.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SiparisFormScreen(sepet: sepet, toplam: toplam),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                'Satın Al',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),

      body: sepet.isEmpty
          ? Center(child: Text('Sepetiniz boş'))
          : ListView.builder(
              itemCount: sepet.length,
              itemBuilder: (context, index) {
                final p = sepet[index];
                final int adet = p['adet'] ?? 1;

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      p['image_url'] ?? '',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  title: Text(p['name'] ?? 'Ürün'),
                  subtitle: Text('${p['price']} ₺'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => adetGuncelle(p['id'], adet - 1),
                      ),
                      Text(
                        '$adet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                        onPressed: () => adetGuncelle(p['id'], adet + 1),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marketapp2/services/AuthService.dart';
import 'package:marketapp2/screens/LoginScreen.dart';
import 'package:marketapp2/screens/SiparisFormScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:marketapp2/data/db_helper.dart';

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

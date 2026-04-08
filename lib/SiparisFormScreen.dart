import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'db_helper.dart';
import 'UserPrefs.dart';
class SiparisFormScreen extends StatefulWidget {
  final List<Map<String, dynamic>> sepet;
  final double toplam;

  const SiparisFormScreen({required this.sepet, required this.toplam});

  @override
  State<SiparisFormScreen> createState() => _SiparisFormScreenState();
}

class _SiparisFormScreenState extends State<SiparisFormScreen> {
  final adController = TextEditingController();
  final soyadController = TextEditingController();
  final telefonController = TextEditingController();
  final adresController = TextEditingController();
  bool yukleniyor = false;

  Future<void> siparisGonder() async {
    setState(() => yukleniyor = true);

    final userId = await UserPrefs.getUserId();

    final body = {
      "UserId": userId,
      "CustomerName": adController.text.trim(),
      "CustomerLastName": soyadController.text.trim(),
      "Telephone": telefonController.text.trim(),
      "Address": adresController.text.trim(),
      "TotalPrice": widget.toplam,
      "State": "Beklemede",
      "OrderTime": DateTime.now().toIso8601String(),
      "Details": widget.sepet.map((p) => {
        "ProductId": int.parse(p['id'].toString()),
        "Piece": int.parse(p['adet'].toString()),
        "UnitPrice": double.parse(p['price'].toString()),
      }).toList(),
    };
    print('Siparis: ${json.encode(body)}');

    final response = await http.post(
      Uri.parse('http://192.168.0.18:5239/api/Order'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    setState(() => yukleniyor = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      await DBHelper.clearSepet();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Siparişiniz alındı!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sipariş Bilgileri')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: adController, decoration: InputDecoration(labelText: 'Ad')),
            TextField(controller: soyadController, decoration: InputDecoration(labelText: 'Soyad')),
            TextField(controller: telefonController, decoration: InputDecoration(labelText: 'Telefon'), keyboardType: TextInputType.phone),
            TextField(controller: adresController, decoration: InputDecoration(labelText: 'Adres')),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: yukleniyor ? null : siparisGonder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 48),
              ),
              child: yukleniyor
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Siparişi Gönder', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
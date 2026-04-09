import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/db_helper.dart';

class AuthService {
  final String baseUrl = "http://192.168.0.18:5239/api";

  Future<bool> login(String username, String password) async {
    final url = "$baseUrl/auth/login";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final token = data["token"];
      final userId = data["Id"];

      await DBHelper.saveTokenandApiUserID(token, userId);

      print(userId.toString());
      //await UserPrefs.saveUserId(userId);

      return true;
    }
    return false;
  }

  Future<String?> getToken() async {
    return await DBHelper.getToken();
  }

  Future<void> logout() async {
    await DBHelper.deleteToken();
  }
}

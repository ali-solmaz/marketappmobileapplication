import 'dart:convert';
import 'package:http/http.dart' as http;

import 'AuthService.dart';

class ApiService {
  final String baseUrl = "http://192.168.0.27:5043/api/";
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<dynamic> getProfile() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/auth/profile"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Oturum süresi doldu");
    }
    throw Exception("Hata: ${response.statusCode}");
  }
}
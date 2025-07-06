import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthService {
  final String _baseUrl = kDebugMode ? 'http://localhost:3000/api' : 'https://api.yesilyol.com/api';

  Future<User> register(String adSoyad, String eposta, String sifre) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ad_soyad': adSoyad,
        'eposta': eposta,
        'sifre': sifre,
      }),
    );

    if (response.statusCode == 201) {
      return User.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Kayıt başarısız: ${response.body}');
    }
  }

  Future<User> login(String eposta, String sifre) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'eposta': eposta,
        'sifre': sifre,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(utf8.decode(response.bodyBytes));
      // TODO: Gelen token'ı flutter_secure_storage gibi güvenli bir yerde sakla.
      return User.fromJson(responseBody['user']);
    } else {
      throw Exception('Giriş başarısız: ${response.body}');
    }
  }
}

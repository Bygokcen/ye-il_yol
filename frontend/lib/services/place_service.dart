import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:frontend/services/auth_service.dart';

class PlaceService {
  final String _baseUrl = kDebugMode ? 'http://localhost:3000/api' : 'https://api.yesilyol.com/api';
  final AuthService _authService = AuthService();

  Future<void> addPlace(Map<String, dynamic> placeData) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/places'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(placeData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add place: ${response.body}');
    }
  }
}

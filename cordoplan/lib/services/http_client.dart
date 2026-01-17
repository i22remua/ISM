// lib/services/http_client.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:http/http.dart' as http;
import '../services/firebase_auth_service.dart';
import 'dart:io';

typedef Headers = Map<String, String>;

class HttpClient {
  final AuthService _authService = AuthService();

  Future<Headers> _getHeaders({bool requireAuth = false}) async {
    final Headers headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await _authService.getCurrentIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        throw Exception('Authentication token is missing.');
      }
    }
    return headers;
  }

  Future<dynamic> get(String url, {bool requireAuth = false}) async {
    try {
      debugPrint('--> GET $url'); // Log de la petición
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint('<-- ${response.statusCode} GET $url'); // Log de la respuesta
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Network Error: Cannot connect to server.');
    }
  }

  Future<dynamic> post(String url, {required Map<String, dynamic> body, bool requireAuth = false}) async {
    try {
      debugPrint('--> POST $url'); // Log de la petición
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      debugPrint('<-- ${response.statusCode} POST $url'); // Log de la respuesta
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Network Error: Cannot connect to server.');
    }
  }

  Future<dynamic> put(String url, {required Map<String, dynamic> body, bool requireAuth = false}) async {
    try {
      debugPrint('--> PUT $url'); // Log de la petición
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      debugPrint('<-- ${response.statusCode} PUT $url'); // Log de la respuesta
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Network Error: Cannot connect to server.');
    }
  }

  Future<Map<String, dynamic>> delete(String url, {bool requireAuth = false}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.delete(Uri.parse(url), headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Network Error: Cannot connect to server.');
    } catch (e) {
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {}; // Devuelve un objeto vacío para indicar éxito
      } else {
        throw Exception('HTTP Error ${response.statusCode}: La respuesta del servidor estaba vacía.');
      }
    }

    try {
      final dynamic body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      if (body is Map<String, dynamic>) {
        final String message = body['message'] ?? 'Unknown error';
        throw Exception('HTTP Error ${response.statusCode}: $message');
      }
      throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
    } on FormatException {
      debugPrint('Error: Server returned non-JSON response:\n${response.body}'); 
      throw Exception('HTTP Error ${response.statusCode}: El servidor devolvió una respuesta inesperada (no es JSON).');
    }
  }
}

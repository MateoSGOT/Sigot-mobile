import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

enum LoadState { idle, loading, loaded, error }

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path, {bool auth = true}) async {
    final token = auth ? await _getToken() : null;
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: _headers(token),
          )
          .timeout(ApiConfig.timeout);
      return _handle(response);
    } on SocketException {
      throw const ApiException('Sin conexión a internet');
    } on TimeoutException {
      throw const ApiException('Tiempo de espera agotado');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final token = auth ? await _getToken() : null;
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
      return _handle(response);
    } on SocketException {
      throw const ApiException('Sin conexión a internet');
    } on TimeoutException {
      throw const ApiException('Tiempo de espera agotado');
    }
  }

  dynamic _handle(http.Response response) {
    // La respuesta puede ser un objeto {data:[...]} o un array [...] directo
    // (según el endpoint), por eso NO se fuerza a Map: se devuelve el JSON tal
    // cual y cada servicio decide cómo leerlo (paridad con la web).
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = null;
      }
    }
    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        throw const ApiException('Sesión expirada', statusCode: 401);
      case 403:
        throw const ApiException('Sin permisos para esta acción',
            statusCode: 403);
      case 500:
        throw const ApiException('Error del servidor, intenta de nuevo',
            statusCode: 500);
      default:
        final msg = (body is Map ? body['message'] as String? : null) ??
            'Error desconocido';
        throw ApiException(msg, statusCode: response.statusCode);
    }
  }
}

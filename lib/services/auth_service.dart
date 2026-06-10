import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/auth_model.dart';
import 'api_service.dart';

class AuthService {
  final _api = ApiService();

  Future<EmpleadoModel> login(String correo, String password) async {
    final res = await _api.post(
      ApiConfig.login,
      {'Correo': correo, 'Password': password},
      auth: false,
    ) as Map<String, dynamic>;

    final tipo = res['tipo'] as String? ?? '';
    if (tipo == 'cliente') {
      throw const ApiException('Esta app es solo para el personal del taller');
    }

    final token = res['token'] as String;
    final empleado =
        EmpleadoModel.fromJson(res['empleado'] as Map<String, dynamic>);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, token);
    await prefs.setString(ApiConfig.empleadoKey, jsonEncode(empleado.toJson()));

    return empleado;
  }

  Future<void> recuperarPassword(String correo) async {
    await _api.post(
      ApiConfig.recuperarPassword,
      {'Correo': correo},
      auth: false,
    );
  }

  Future<EmpleadoModel?> getSavedEmpleado() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConfig.tokenKey);
    final json = prefs.getString(ApiConfig.empleadoKey);
    if (token == null || json == null) return null;
    return EmpleadoModel.fromJson(
        jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
    await prefs.remove(ApiConfig.empleadoKey);
  }
}

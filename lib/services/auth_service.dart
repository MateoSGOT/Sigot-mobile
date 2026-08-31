import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/auth_model.dart';
import 'api_service.dart';

/// Sesión resultante del login: puede ser de un empleado (personal del taller)
/// o de un cliente (panel del cliente / portal).
class AuthSession {
  final String tipo; // 'empleado' | 'cliente'
  final EmpleadoModel? empleado;
  final ClienteModel? cliente;

  const AuthSession({required this.tipo, this.empleado, this.cliente});

  bool get isCliente => tipo == 'cliente';
}

class AuthService {
  final _api = ApiService();

  Future<AuthSession> login(String correo, String password) async {
    final res = await _api.post(
      ApiConfig.login,
      {'Correo': correo, 'Password': password},
      auth: false,
    ) as Map<String, dynamic>;

    final tipo = (res['tipo'] as String?) ?? 'empleado';
    final token = res['token'] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, token);
    await prefs.setString(ApiConfig.tipoKey, tipo);

    if (tipo == 'cliente') {
      final cliente =
          ClienteModel.fromJson(res['cliente'] as Map<String, dynamic>);
      await prefs.setString(
          ApiConfig.clienteKey, jsonEncode(cliente.toJson()));
      await prefs.remove(ApiConfig.empleadoKey);
      return AuthSession(tipo: 'cliente', cliente: cliente);
    } else {
      final empleado =
          EmpleadoModel.fromJson(res['empleado'] as Map<String, dynamic>);
      await prefs.setString(
          ApiConfig.empleadoKey, jsonEncode(empleado.toJson()));
      await prefs.remove(ApiConfig.clienteKey);
      return AuthSession(tipo: 'empleado', empleado: empleado);
    }
  }

  Future<void> recuperarPassword(String correo) async {
    await _api.post(
      ApiConfig.recuperarPassword,
      {'Correo': correo},
      auth: false,
    );
  }

  Future<AuthSession?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConfig.tokenKey);
    if (token == null) return null;
    final tipo = prefs.getString(ApiConfig.tipoKey) ?? 'empleado';
    if (tipo == 'cliente') {
      final json = prefs.getString(ApiConfig.clienteKey);
      if (json == null) return null;
      return AuthSession(
        tipo: 'cliente',
        cliente:
            ClienteModel.fromJson(jsonDecode(json) as Map<String, dynamic>),
      );
    } else {
      final json = prefs.getString(ApiConfig.empleadoKey);
      if (json == null) return null;
      return AuthSession(
        tipo: 'empleado',
        empleado:
            EmpleadoModel.fromJson(jsonDecode(json) as Map<String, dynamic>),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
    await prefs.remove(ApiConfig.empleadoKey);
    await prefs.remove(ApiConfig.clienteKey);
    await prefs.remove(ApiConfig.tipoKey);
  }
}

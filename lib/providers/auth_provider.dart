import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

enum AuthState { idle, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  AuthState _state = AuthState.idle;
  String _tipo = 'empleado';
  EmpleadoModel? _empleado;
  ClienteModel? _cliente;
  String? _error;

  AuthState get state => _state;
  EmpleadoModel? get empleado => _empleado;
  ClienteModel? get cliente => _cliente;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isCliente => _tipo == 'cliente';

  void _applySession(AuthSession s) {
    _tipo = s.tipo;
    _empleado = s.empleado;
    _cliente = s.cliente;
  }

  Future<void> checkAuth() async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      final session = await _service.getSavedSession();
      if (session != null) {
        _applySession(session);
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (_) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String correo, String password) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();
    try {
      _applySession(await _service.login(correo, password));
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error inesperado';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _empleado = null;
    _cliente = null;
    _tipo = 'empleado';
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}

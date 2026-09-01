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
  List<String> _permisos = [];

  AuthState get state => _state;
  EmpleadoModel? get empleado => _empleado;
  ClienteModel? get cliente => _cliente;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isCliente => _tipo == 'cliente';
  List<String> get permisos => _permisos;

  /// Si el empleado logueado tiene el permiso exacto (ej. 'DASHBOARD.VER_COMPRAS').
  bool hasPermiso(String permiso) => _permisos.contains(permiso);

  void _applySession(AuthSession s) {
    _tipo = s.tipo;
    _empleado = s.empleado;
    _cliente = s.cliente;
  }

  Future<void> _loadPermisos() async {
    if (_tipo == 'cliente' || _empleado == null) {
      _permisos = [];
      return;
    }
    _permisos = await _service.getPermisos(_empleado!.idRol);
  }

  Future<void> checkAuth() async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      final session = await _service.getSavedSession();
      if (session != null) {
        _applySession(session);
        await _loadPermisos();
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
      await _loadPermisos();
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

  /// Actualiza el cliente en memoria y en caché local tras editar el perfil.
  Future<void> updateCliente(ClienteModel cliente) async {
    _cliente = cliente;
    await _service.saveCliente(cliente);
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout();
    _empleado = null;
    _cliente = null;
    _permisos = [];
    _tipo = 'empleado';
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}

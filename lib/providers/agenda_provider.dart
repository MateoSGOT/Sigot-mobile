import 'package:flutter/material.dart';
import '../models/agenda_model.dart';
import '../models/orden_model.dart';
import '../services/agenda_service.dart';
import '../services/api_service.dart';

class AgendaProvider extends ChangeNotifier {
  final _service = AgendaService();

  LoadState _state = LoadState.idle;
  List<AgendaModel> _items = [];
  List<ClienteCatalogo> _clientes = [];
  String? _error;
  String _search = '';

  LoadState get state => _state;
  String? get error => _error;
  List<ClienteCatalogo> get clientes => _clientes;

  List<AgendaModel> get filtered {
    if (_search.isEmpty) return _items;
    final q = _search.toLowerCase();
    return _items
        .where((a) =>
            a.cliente.toLowerCase().contains(q) ||
            a.vehiculo.toLowerCase().contains(q) ||
            a.empleado.toLowerCase().contains(q))
        .toList();
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  Future<void> load() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.getAgenda();
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (_) {
      _error = 'Error al cargar agenda';
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadClientes() async {
    try {
      _clientes = await _service.getClientes();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> crearCita(Map<String, dynamic> body) async {
    try {
      final nueva = await _service.crearCita(body);
      _items.insert(0, nueva);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> generarOrden(int idAgenda) async {
    try {
      await _service.generarOrden(idAgenda);
      await load();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}

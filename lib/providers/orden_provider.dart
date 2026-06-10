import 'package:flutter/material.dart';
import '../models/orden_model.dart';
import '../services/orden_service.dart';
import '../services/api_service.dart';

class OrdenProvider extends ChangeNotifier {
  final _service = OrdenService();

  LoadState _state = LoadState.idle;
  List<OrdenModel> _items = [];
  OrdenModel? _detalle;
  LoadState _detalleState = LoadState.idle;
  String? _error;
  String _search = '';
  String? _filterEstado;

  LoadState get state => _state;
  LoadState get detalleState => _detalleState;
  OrdenModel? get detalle => _detalle;
  String? get error => _error;
  String? get filterEstado => _filterEstado;

  List<OrdenModel> get filtered {
    var list = _items;
    if (_filterEstado != null) {
      list = list.where((o) => o.estadoFlujo == _filterEstado).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((o) =>
              o.vehiculo.toLowerCase().contains(q) ||
              o.cliente.toLowerCase().contains(q) ||
              (o.diagnostico?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return list;
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  void setFilter(String? estado) {
    _filterEstado = estado;
    notifyListeners();
  }

  Future<void> load() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.getOrdenes();
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (_) {
      _error = 'Error al cargar órdenes';
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadDetalle(int id) async {
    _detalleState = LoadState.loading;
    _detalle = null;
    notifyListeners();
    try {
      _detalle = await _service.getOrdenDetalle(id);
      _detalleState = LoadState.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _detalleState = LoadState.error;
    } catch (_) {
      _error = 'Error al cargar detalle';
      _detalleState = LoadState.error;
    }
    notifyListeners();
  }
}

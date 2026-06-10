import 'package:flutter/material.dart';
import '../models/vehiculo_model.dart';
import '../services/vehiculo_service.dart';
import '../services/api_service.dart';

class VehiculoProvider extends ChangeNotifier {
  final _service = VehiculoService();

  LoadState _state = LoadState.idle;
  List<VehiculoModel> _items = [];
  String? _error;
  String _search = '';

  LoadState get state => _state;
  String? get error => _error;

  List<VehiculoModel> get filtered {
    if (_search.isEmpty) return _items;
    final q = _search.toLowerCase();
    return _items
        .where((v) =>
            v.placa.toLowerCase().contains(q) ||
            v.marca.toLowerCase().contains(q) ||
            v.cliente.toLowerCase().contains(q))
        .toList();
  }

  List<VehiculoModel> get all => _items;

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  Future<void> load() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.getVehiculos();
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (_) {
      _error = 'Error al cargar vehículos';
      _state = LoadState.error;
    }
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/portal_models.dart';
import '../models/vehiculo_model.dart';
import '../services/portal_service.dart';
import '../services/api_service.dart';

class PortalProvider extends ChangeNotifier {
  final _service = PortalService();

  LoadState _state = LoadState.idle;
  String? _error;
  List<VehiculoModel> _vehiculos = [];
  List<PortalOrden> _ordenes = [];
  List<PortalCita> _citas = [];

  LoadState get state => _state;
  String? get error => _error;
  List<VehiculoModel> get vehiculos => _vehiculos;
  List<PortalOrden> get ordenes => _ordenes;
  List<PortalCita> get citas => _citas;

  Future<void> load() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();
    try {
      _vehiculos = await _service.getVehiculos();
      _ordenes = await _service.getOrdenes();
      _citas = await _service.getCitas();
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (_) {
      _error = 'Error al cargar tu información';
      _state = LoadState.error;
    }
    notifyListeners();
  }
}

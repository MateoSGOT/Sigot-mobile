import 'package:flutter/material.dart';
import '../models/auth_model.dart';
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
  List<EmpleadoDisponible> _empleadosDisponibles = [];

  LoadState get state => _state;
  String? get error => _error;
  List<VehiculoModel> get vehiculos => _vehiculos;
  List<PortalOrden> get ordenes => _ordenes;
  List<PortalCita> get citas => _citas;
  List<EmpleadoDisponible> get empleadosDisponibles => _empleadosDisponibles;

  /// Carga los mecánicos/técnicos disponibles para agendar en [fecha]
  /// (formato yyyy-MM-dd). Falla en silencio: si no carga, el formulario
  /// simplemente no muestra el selector y el backend asigna uno por defecto.
  Future<void> loadEmpleadosDisponibles(String fecha) async {
    try {
      _empleadosDisponibles = await _service.getEmpleadosDisponibles(fecha);
      notifyListeners();
    } catch (_) {}
  }

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

  /// Agenda una cita. Devuelve `null` si todo bien, o el mensaje de error.
  Future<String?> crearCita(Map<String, dynamic> data) async {
    try {
      await _service.createCita(data);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo agendar la cita';
    }
  }

  /// Actualiza correo/teléfono del cliente. Devuelve el cliente actualizado,
  /// o `null` si falló (el mensaje de error queda en [error]).
  Future<ClienteModel?> updatePerfil(
      {String? correo, String? telefono, String? documento}) async {
    try {
      final cliente = await _service.updatePerfil(
          correo: correo, telefono: telefono, documento: documento);
      _error = null;
      return cliente;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      _error = 'No se pudo actualizar el perfil';
      notifyListeners();
      return null;
    }
  }

  /// Cancela una cita. Devuelve `null` si todo bien, o el mensaje de error.
  Future<String?> cancelarCita(int id, String motivo) async {
    try {
      await _service.cancelCita(id, motivo);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo cancelar la cita';
    }
  }
}

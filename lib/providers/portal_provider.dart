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
  List<HoraOcupada> _horasOcupadas = [];

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

  /// Franjas ocupadas (citas + novedades por rango horario) del técnico
  /// elegido en la fecha elegida -- paridad con PortalPage.jsx de la web:
  /// solo se consulta cuando el cliente elige un técnico específico ("cualquiera
  /// disponible" no filtra horas, el backend asigna uno libre al agendar).
  /// Un empleado con una novedad de 9 a 10am y otra de 1pm en adelante queda
  /// correctamente disponible entre 10am y 1pm -- cada franja se evalúa por
  /// separado, no se bloquea el día completo por tener alguna novedad.
  Future<void> loadHorasOcupadas(int idEmpleado, String fecha) async {
    try {
      _horasOcupadas = await _service.getHorasOcupadas(idEmpleado, fecha);
      notifyListeners();
    } catch (_) {
      _horasOcupadas = [];
    }
  }

  void limpiarHorasOcupadas() {
    _horasOcupadas = [];
    notifyListeners();
  }

  int _toMin(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  /// Si el slot [hora] (duración fija de 30 min en el selector) choca con
  /// alguna franja ocupada ya cargada con [loadHorasOcupadas].
  bool horaBloqueada(String hora) {
    final ini = _toMin(hora);
    const duracionSlot = 30;
    return _horasOcupadas.any((o) {
      final oIni = _toMin(o.hora);
      final oFin = oIni + (o.duracionMin > 0 ? o.duracionMin : 60);
      return ini < oFin && oIni < ini + duracionSlot;
    });
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

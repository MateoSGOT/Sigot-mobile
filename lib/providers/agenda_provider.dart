import 'package:flutter/material.dart';
import '../models/agenda_model.dart';
import '../models/auth_model.dart';
import '../models/novedad_model.dart';
import '../models/orden_model.dart';
import '../services/agenda_service.dart';
import '../services/api_service.dart';

class AgendaProvider extends ChangeNotifier {
  final _service = AgendaService();

  LoadState _state = LoadState.idle;
  List<AgendaModel> _items = [];
  List<ClienteCatalogo> _clientes = [];
  List<EmpleadoModel> _empleados = [];
  List<NovedadModel> _novedades = [];
  String? _error;
  String _search = '';
  int _statusFilter = 0; // 0=Todas, 1=Pendientes, 2=Realizadas, 3=Canceladas

  LoadState get state => _state;
  String? get error => _error;
  List<ClienteCatalogo> get clientes => _clientes;
  List<EmpleadoModel> get empleados => _empleados;
  int get statusFilter => _statusFilter;

  /// Agrupa los estados reales de la cita en los 3 baldes que pide el
  /// filtro: Pendientes (incluye Confirmada), Realizadas (Atendida) y
  /// Canceladas (incluye NoAsistio).
  static int _bucket(AgendaModel a) => switch (a.estadoCita) {
        'Atendida' => 2,
        'Cancelada' || 'NoAsistio' => 3,
        _ => 1, // Pendiente, Confirmada
      };

  List<AgendaModel> get filtered {
    var items = _items;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      items = items
          .where((a) =>
              a.cliente.toLowerCase().contains(q) ||
              a.vehiculo.toLowerCase().contains(q) ||
              a.empleado.toLowerCase().contains(q))
          .toList();
    }
    if (_statusFilter != 0) {
      items = items.where((a) => _bucket(a) == _statusFilter).toList();
    } else {
      // Por defecto: pendientes primero, luego realizadas, luego canceladas.
      items = [...items]..sort((a, b) => _bucket(a).compareTo(_bucket(b)));
    }
    return items;
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  void setStatusFilter(int v) {
    _statusFilter = v;
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

  /// Carga la lista de empleados para asignar la cita. Si el rol logueado no
  /// tiene permiso para listar empleados (ej. Mecánico), falla en silencio y
  /// el formulario sigue asignando la cita al empleado logueado.
  Future<void> loadEmpleados() async {
    try {
      _empleados = await _service.getEmpleados();
      notifyListeners();
    } catch (_) {}
  }

  /// Carga las novedades (ausencias) de empleados. Falla en silencio: sin
  /// permiso para listarlas, el formulario simplemente no filtra por ellas.
  Future<void> loadNovedades() async {
    try {
      _novedades = await _service.getNovedades();
      notifyListeners();
    } catch (_) {}
  }

  /// Empleados con una novedad de DÍA COMPLETO vigente en [ymd]
  /// ('yyyy-MM-dd'): no deben aparecer como opción para asignarles una cita
  /// ese día. Una novedad con rango de horas NO excluye al empleado del día
  /// completo -- deja disponibles las horas fuera de su rango (ver
  /// [horaBloqueadaPorNovedad]).
  Set<int> empleadosBloqueadosEnFecha(String? ymd) {
    if (ymd == null || ymd.isEmpty) return {};
    return _novedades
        .where((n) => n.cubreFecha(ymd) && n.esDiaCompleto)
        .map((n) => n.idEmpleado)
        .whereType<int>()
        .toSet();
  }

  int _toMin(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  /// Si el slot [hora] (con duración [duracionMin]) choca con alguna novedad
  /// POR RANGO del empleado [idEmpleado] en [ymd]. Cada novedad se evalúa por
  /// separado, así que un empleado con novedad 9-10am y otra 1pm-fin de
  /// jornada queda disponible entre 10am y 1pm.
  bool horaBloqueadaPorNovedad(int? idEmpleado, String? ymd, String hora,
      {int duracionMin = 60}) {
    if (idEmpleado == null || ymd == null || ymd.isEmpty) return false;
    final ini = _toMin(hora);
    final fin = ini + duracionMin;
    return _novedades.where((n) {
      return n.idEmpleado == idEmpleado &&
          n.cubreFecha(ymd) &&
          !n.esDiaCompleto;
    }).any((n) {
      final nIni = _toMin(n.horaInicio!);
      final nFin = _toMin(n.horaFin!);
      return ini < nFin && nIni < fin;
    });
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

  /// Genera la orden de trabajo de una cita. Devuelve el id de la orden
  /// creada (para navegar directo a su detalle) o `null` si falló.
  Future<int?> generarOrden(int idAgenda) async {
    try {
      final orden = await _service.generarOrden(idAgenda);
      await load();
      return orden.idOrden;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }
}

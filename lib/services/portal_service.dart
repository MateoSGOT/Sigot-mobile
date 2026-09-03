import '../config/api_config.dart';
import '../models/auth_model.dart';
import '../models/portal_models.dart';
import '../models/vehiculo_model.dart';
import 'api_service.dart';

class PortalService {
  final _api = ApiService();

  // Extrae la lista de la respuesta, tolere array directo o {data:[...]}.
  List _asList(dynamic res) {
    if (res is List) return res;
    if (res is Map) return (res['data'] ?? res['citas'] ?? const []) as List;
    return const [];
  }

  Future<List<VehiculoModel>> getVehiculos() async {
    final res = await _api.get(ApiConfig.portalVehiculos);
    return _asList(res)
        .whereType<Map>()
        .map((e) => VehiculoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<PortalOrden>> getOrdenes() async {
    final res = await _api.get(ApiConfig.portalOrdenes);
    return _asList(res)
        .whereType<Map>()
        .map((e) => PortalOrden.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<PortalCita>> getCitas() async {
    final res = await _api.get(ApiConfig.portalCitas);
    return _asList(res)
        .whereType<Map>()
        .map((e) => PortalCita.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> createCita(Map<String, dynamic> data) async {
    await _api.post(ApiConfig.portalCitas, data);
  }

  Future<void> cancelCita(int id, String motivo) async {
    await _api.patch('${ApiConfig.portalCitas}/$id/cancelar',
        body: {'motivo': motivo});
  }

  Future<ClienteModel> updatePerfil(
      {String? correo, String? telefono, String? documento}) async {
    final body = <String, dynamic>{
      if (correo != null) 'Correo': correo,
      if (telefono != null) 'Contacto': telefono,
      if (documento != null) 'Documento': documento,
    };
    final res =
        await _api.put(ApiConfig.portalPerfil, body) as Map<String, dynamic>;
    final data = res['data'] as Map<String, dynamic>? ?? res;
    return ClienteModel.fromJson(data);
  }

  Future<List<EmpleadoDisponible>> getEmpleadosDisponibles(
      String fecha) async {
    final res = await _api
        .get('${ApiConfig.portalEmpleadosDisponibles}?fecha=$fecha');
    return _asList(res)
        .whereType<Map>()
        .map((e) => EmpleadoDisponible.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Franjas ocupadas del técnico [idEmpleado] en [fecha] (citas + novedades
  /// con rango horario) -- para filtrar el select de horas sin exponer toda
  /// la agenda del taller.
  Future<List<HoraOcupada>> getHorasOcupadas(
      int idEmpleado, String fecha) async {
    final res = await _api.get(
        '${ApiConfig.portalHorasOcupadas}?id_empleado=$idEmpleado&fecha=$fecha');
    return _asList(res)
        .whereType<Map>()
        .map((e) => HoraOcupada.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

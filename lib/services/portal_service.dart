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

  Future<ClienteModel> updatePerfil({String? correo, String? telefono}) async {
    final body = <String, dynamic>{
      if (correo != null) 'Correo': correo,
      if (telefono != null) 'Contacto': telefono,
    };
    final res =
        await _api.put(ApiConfig.portalPerfil, body) as Map<String, dynamic>;
    final data = res['data'] as Map<String, dynamic>? ?? res;
    return ClienteModel.fromJson(data);
  }
}

import '../config/api_config.dart';
import '../models/agenda_model.dart';
import '../models/auth_model.dart';
import '../models/novedad_model.dart';
import '../models/orden_model.dart';
import 'api_service.dart';

class AgendaService {
  final _api = ApiService();

  Future<List<AgendaModel>> getAgenda() async {
    final res = await _api.get(ApiConfig.agenda) as Map<String, dynamic>;
    final list = res['data'] as List? ?? res['agenda'] as List? ?? [];
    return list
        .map((e) => AgendaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ClienteCatalogo>> getClientes() async {
    final res = await _api.get(ApiConfig.clientes) as Map<String, dynamic>;
    final list = res['data'] as List? ?? res['clientes'] as List? ?? [];
    return list
        .map((e) => ClienteCatalogo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AgendaModel> crearCita(Map<String, dynamic> body) async {
    final res =
        await _api.post(ApiConfig.agenda, body) as Map<String, dynamic>;
    final data = res['data'] as Map<String, dynamic>? ?? res;
    return AgendaModel.fromJson(data);
  }

  Future<OrdenModel> generarOrden(int idAgenda) async {
    final res = await _api.post('${ApiConfig.agenda}/$idAgenda/orden', {})
        as Map<String, dynamic>;
    final data = res['data'] as Map<String, dynamic>? ?? res;
    return OrdenModel.fromJson(data);
  }

  Future<List<EmpleadoModel>> getEmpleados() async {
    final res = await _api.get(ApiConfig.empleados) as Map<String, dynamic>;
    final list = res['data'] as List? ?? [];
    return list
        .map((e) => EmpleadoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NovedadModel>> getNovedades() async {
    final res = await _api.get(ApiConfig.novedades) as Map<String, dynamic>;
    final list = res['data'] as List? ?? [];
    return list
        .map((e) => NovedadModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

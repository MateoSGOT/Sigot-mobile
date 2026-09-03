import '../config/api_config.dart';
import '../models/orden_model.dart';
import 'api_service.dart';

class OrdenService {
  final _api = ApiService();

  Future<List<OrdenModel>> getOrdenes() async {
    final res =
        await _api.get(ApiConfig.ordenes) as Map<String, dynamic>;
    final list = res['data'] as List? ?? res['ordenes'] as List? ?? [];
    return list
        .map((e) => OrdenModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrdenModel> getOrdenDetalle(int id) async {
    final res =
        await _api.get('${ApiConfig.ordenes}/$id') as Map<String, dynamic>;
    final data = res['data'] as Map<String, dynamic>? ?? res;
    return OrdenModel.fromJson(data);
  }

  /// "Necesito más tiempo": el técnico avisa que el trabajo en curso va a
  /// tardar más de lo estimado. El backend extiende la duración de la cita y
  /// devuelve la orden actualizada junto con las citas del mismo técnico que
  /// quedaron en choque (si las hay); esas ya fueron notificadas por correo
  /// por el propio backend, no se bloquea nada acá.
  Future<ExtenderDuracionResult> extenderDuracion(
      int idOrden, int minutosAdicionales) async {
    final res = await _api.patch(
      '${ApiConfig.ordenes}/$idOrden/extender-duracion',
      body: {'minutosAdicionales': minutosAdicionales},
    ) as Map<String, dynamic>;
    final data = res['data'] as Map<String, dynamic>? ?? res;
    final conflictos = (data['conflictosDetectados'] as List? ?? [])
        .map((c) => ConflictoCita.fromJson(c as Map<String, dynamic>))
        .toList();
    return ExtenderDuracionResult(
      orden: OrdenModel.fromJson(data),
      conflictos: conflictos,
    );
  }
}

class ExtenderDuracionResult {
  final OrdenModel orden;
  final List<ConflictoCita> conflictos;

  const ExtenderDuracionResult({required this.orden, required this.conflictos});
}

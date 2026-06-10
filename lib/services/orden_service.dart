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
}

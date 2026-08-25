import '../config/api_config.dart';
import '../models/compra_model.dart';
import 'api_service.dart';

class CompraService {
  final _api = ApiService();

  Future<List<CompraModel>> getCompras() async {
    final res = await _api.get(ApiConfig.compras) as Map<String, dynamic>;
    final list = res['data'] as List? ?? res['compras'] as List? ?? [];
    return list
        .map((e) => CompraModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import '../config/api_config.dart';
import '../models/compra_model.dart';
import 'api_service.dart';

class CompraService {
  final _api = ApiService();

  Future<List<CompraModel>> getCompras() async {
    final res = await _api.get(ApiConfig.compras);
    // La respuesta puede venir como array directo [...] o como {data:[...]}
    // (o {compras:[...]}). Se tolera cualquiera, igual que la web.
    final List raw = res is List
        ? res
        : (res is Map
            ? (res['data'] ?? res['compras'] ?? const []) as List
            : const []);
    return raw
        .whereType<Map>()
        .map((e) => CompraModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

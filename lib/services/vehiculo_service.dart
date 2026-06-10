import '../config/api_config.dart';
import '../models/vehiculo_model.dart';
import 'api_service.dart';

class VehiculoService {
  final _api = ApiService();

  Future<List<VehiculoModel>> getVehiculos() async {
    final res =
        await _api.get(ApiConfig.vehiculos) as Map<String, dynamic>;
    final list =
        res['data'] as List? ?? res['vehiculos'] as List? ?? [];
    return list
        .map((e) => VehiculoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

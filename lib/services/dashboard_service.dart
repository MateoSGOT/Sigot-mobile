import '../config/api_config.dart';
import '../models/dashboard_model.dart';
import 'api_service.dart';

class DashboardService {
  final _api = ApiService();

  String _qs({String? desde, String? hasta, String? agrupacion, int? limit}) {
    final p = <String>[];
    if (desde != null) p.add('desde=$desde');
    if (hasta != null) p.add('hasta=$hasta');
    if (agrupacion != null) p.add('agrupacion=$agrupacion');
    if (limit != null) p.add('limit=$limit');
    return p.isEmpty ? '' : '?${p.join('&')}';
  }

  Future<DashboardResumen> getResumen(
      {String? desde, String? hasta, String? agrupacion}) async {
    final res = await _api.get(
            '${ApiConfig.dashboardResumen}${_qs(desde: desde, hasta: hasta, agrupacion: agrupacion)}')
        as Map<String, dynamic>;
    final data = (res['data'] ?? res) as Map<String, dynamic>;
    return DashboardResumen.fromJson(data);
  }

  Future<IngresosSerie> getIngresos(
      {String? desde, String? hasta, String? agrupacion}) async {
    final res = await _api.get(
            '${ApiConfig.dashboardIngresos}${_qs(desde: desde, hasta: hasta, agrupacion: agrupacion)}')
        as Map<String, dynamic>;
    final data = (res['data'] ?? res) as Map<String, dynamic>;
    return IngresosSerie.fromJson(data);
  }

  Future<List<TopServicio>> getTopServicios(
      {String? desde, String? hasta, String? agrupacion, int limit = 6}) async {
    final res = await _api.get(
            '${ApiConfig.dashboardTopServicios}${_qs(desde: desde, hasta: hasta, agrupacion: agrupacion, limit: limit)}')
        as Map<String, dynamic>;
    final list = res['data'] as List? ?? [];
    return list
        .map((e) => TopServicio.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

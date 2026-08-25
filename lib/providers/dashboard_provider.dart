import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final _service = DashboardService();

  LoadState _state = LoadState.idle;
  DashboardResumen _resumen = const DashboardResumen();
  IngresosSerie _ingresos = const IngresosSerie();
  List<TopServicio> _topServicios = const [];
  String _preset = 'mes';
  String? _error;

  LoadState get state => _state;
  DashboardResumen get resumen => _resumen;
  IngresosSerie get ingresos => _ingresos;
  List<TopServicio> get topServicios => _topServicios;
  String get preset => _preset;
  String? get error => _error;

  static const presets = ['hoy', 'semana', 'mes', 'anio'];
  static const presetLabels = ['Hoy', 'Semana', 'Mes', 'Año'];
  int get presetIndex => presets.indexOf(_preset);

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  ({String desde, String hasta, String agrupacion}) _range(String preset) {
    final hoy = DateTime.now();
    switch (preset) {
      case 'hoy':
        return (desde: _fmt(hoy), hasta: _fmt(hoy), agrupacion: 'dia');
      case 'semana':
        final d = hoy.subtract(Duration(days: hoy.weekday - 1)); // lunes
        return (desde: _fmt(d), hasta: _fmt(hoy), agrupacion: 'dia');
      case 'anio':
        return (desde: _fmt(DateTime(hoy.year, 1, 1)), hasta: _fmt(hoy), agrupacion: 'mes');
      case 'mes':
      default:
        return (
          desde: _fmt(DateTime(hoy.year, hoy.month, 1)),
          hasta: _fmt(hoy),
          agrupacion: 'dia'
        );
    }
  }

  Future<void> setPreset(String p) async {
    if (p == _preset && _state == LoadState.loaded) return;
    _preset = p;
    await load();
  }

  Future<void> load() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    final r = _range(_preset);
    try {
      // Se lanzan en paralelo. El resumen (KPIs) manda el estado; la serie y el
      // top de servicios son best-effort (no rompen la carga si fallan).
      final resumenF = _service.getResumen(
          desde: r.desde, hasta: r.hasta, agrupacion: r.agrupacion);
      final ingresosF = _service
          .getIngresos(desde: r.desde, hasta: r.hasta, agrupacion: r.agrupacion)
          .catchError((_) => const IngresosSerie());
      final topF = _service
          .getTopServicios(
              desde: r.desde, hasta: r.hasta, agrupacion: r.agrupacion)
          .catchError((_) => const <TopServicio>[]);

      _resumen = await resumenF;
      _ingresos = await ingresosF;
      _topServicios = await topF;
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (_) {
      _error = 'Error al cargar el dashboard';
      _state = LoadState.error;
    }
    notifyListeners();
  }
}

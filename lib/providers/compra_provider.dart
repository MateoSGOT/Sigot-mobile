import 'package:flutter/material.dart';
import '../models/compra_model.dart';
import '../services/compra_service.dart';
import '../services/api_service.dart';

/// Filtro por estado, en paridad con la web (todas / vigentes / anuladas).
enum CompraFilter { todas, vigentes, anuladas }

class CompraProvider extends ChangeNotifier {
  final _service = CompraService();

  LoadState _state = LoadState.idle;
  List<CompraModel> _items = [];
  String? _error;
  String _search = '';
  CompraFilter _filter = CompraFilter.todas;

  LoadState get state => _state;
  String? get error => _error;
  CompraFilter get filter => _filter;

  List<CompraModel> get filtered {
    var list = _items;
    if (_filter == CompraFilter.vigentes) {
      list = list.where((c) => !c.anulada).toList();
    } else if (_filter == CompraFilter.anuladas) {
      list = list.where((c) => c.anulada).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((c) =>
              c.proveedor.toLowerCase().contains(q) ||
              c.repuesto.toLowerCase().contains(q))
          .toList();
    }
    // Más recientes primero (id autoincremental como respaldo).
    final sorted = [...list]..sort((a, b) => b.idCompra.compareTo(a.idCompra));
    return sorted;
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  void setFilter(CompraFilter f) {
    _filter = f;
    notifyListeners();
  }

  Future<void> load() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.getCompras();
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (_) {
      _error = 'Error al cargar compras';
      _state = LoadState.error;
    }
    notifyListeners();
  }
}

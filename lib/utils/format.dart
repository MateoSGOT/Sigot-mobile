import 'package:intl/intl.dart';

/// Separador de miles con punto (formato es-CO), sin dependencia de datos de
/// locale para números (evita fallos si el locale no está inicializado).
String _thousands(num v) {
  final s = v.round().abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}$b';
}

/// Moneda COP en paridad con `formatCurrency` de la web (`$ 1.234`, 0 decimales).
String formatCurrency(num? v) => v == null ? '—' : '\$ ${_thousands(v)}';

/// Versión compacta para ejes de gráficos: `$1.2k`, `$3M`.
String formatCurrencyCompact(num v) {
  if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}M';
  if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
  return '\$${v.round()}';
}

/// Fecha corta dd/MM/yyyy (paridad con `formatDate` de la web).
String formatDate(String? s) {
  if (s == null || s.isEmpty) return '—';
  try {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(s));
  } catch (_) {
    return s;
  }
}

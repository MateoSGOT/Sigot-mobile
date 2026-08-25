/// Resumen de KPIs del rango (paridad con `/api/dashboard/resumen` de la web).
class DashboardResumen {
  final double ingresoTotal;
  final int ordenesRealizadas;
  final double ticketPromedio;
  final int stockBajo;
  final int stockCritico;

  const DashboardResumen({
    this.ingresoTotal = 0,
    this.ordenesRealizadas = 0,
    this.ticketPromedio = 0,
    this.stockBajo = 0,
    this.stockCritico = 0,
  });

  factory DashboardResumen.fromJson(Map<String, dynamic> json) =>
      DashboardResumen(
        ingresoTotal: ((json['ingresoTotal'] ?? 0) as num).toDouble(),
        ordenesRealizadas: (json['ordenesRealizadas'] ?? 0) as int,
        ticketPromedio: ((json['ticketPromedio'] ?? 0) as num).toDouble(),
        stockBajo: (json['stockBajo'] ?? 0) as int,
        stockCritico: (json['stockCritico'] ?? 0) as int,
      );
}

/// Punto de la serie de ingresos.
class IngresoPunto {
  final String periodo;
  final double total;

  const IngresoPunto({required this.periodo, required this.total});

  factory IngresoPunto.fromJson(Map<String, dynamic> json) => IngresoPunto(
        periodo: (json['periodo'] ?? '') as String,
        total: ((json['total'] ?? 0) as num).toDouble(),
      );
}

class IngresosSerie {
  final double total;
  final String agrupacion;
  final List<IngresoPunto> series;

  const IngresosSerie({
    this.total = 0,
    this.agrupacion = 'dia',
    this.series = const [],
  });

  factory IngresosSerie.fromJson(Map<String, dynamic> json) => IngresosSerie(
        total: ((json['total'] ?? 0) as num).toDouble(),
        agrupacion: (json['agrupacion'] ?? 'dia') as String,
        series: (json['series'] as List? ?? [])
            .map((e) => IngresoPunto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Servicio más realizado.
class TopServicio {
  final String nombre;
  final int veces;

  const TopServicio({required this.nombre, required this.veces});

  factory TopServicio.fromJson(Map<String, dynamic> json) => TopServicio(
        nombre: (json['nombre'] ?? '') as String,
        veces: (json['veces'] ?? 0) as int,
      );
}

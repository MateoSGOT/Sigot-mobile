/// Novedad de un empleado (ausencia, incapacidad, etc.) que bloquea
/// asignarlo a una cita mientras esté vigente. Paridad con AgendaPage.jsx
/// de la web (empleadosBloqueadosEnFecha).
class NovedadModel {
  final int? idEmpleado;
  final String? fechaNovedad;
  final String? fechaRealizacion;
  final bool estado;

  const NovedadModel({
    this.idEmpleado,
    this.fechaNovedad,
    this.fechaRealizacion,
    required this.estado,
  });

  factory NovedadModel.fromJson(Map<String, dynamic> json) => NovedadModel(
        idEmpleado: json['id_empleado'] as int?,
        fechaNovedad: (json['Fecha_Novedad'] as String?)?.split('T').first,
        fechaRealizacion:
            (json['FechaRealizacion'] as String?)?.split('T').first,
        estado: json['Estado'] != 0 && json['Estado'] != false,
      );

  /// Si la novedad (de un solo día si no hay FechaRealizacion) cubre [ymd]
  /// ('yyyy-MM-dd').
  bool cubreFecha(String ymd) {
    final inicio = fechaNovedad;
    if (inicio == null || inicio.isEmpty) return false;
    final fin = (fechaRealizacion?.isNotEmpty ?? false)
        ? fechaRealizacion!
        : inicio;
    return estado && ymd.compareTo(inicio) >= 0 && ymd.compareTo(fin) <= 0;
  }
}

/// Novedad de un empleado (ausencia, incapacidad, etc.) que bloquea
/// asignarlo a una cita mientras esté vigente. Paridad con AgendaPage.jsx
/// de la web (empleadosBloqueadosEnFecha / horaBloqueadaPorNovedad).
///
/// Puede cubrir el día COMPLETO (sin horaInicio/horaFin) o solo un RANGO de
/// horas ese día -- un empleado puede tener varias novedades por rango en el
/// mismo día (ej. 9-10am y luego 1pm-fin de jornada), quedando disponible en
/// los huecos entre ellas.
class NovedadModel {
  final int? idEmpleado;
  final String? fechaNovedad;
  final String? fechaRealizacion;
  final String? horaInicio;
  final String? horaFin;
  final bool estado;

  const NovedadModel({
    this.idEmpleado,
    this.fechaNovedad,
    this.fechaRealizacion,
    this.horaInicio,
    this.horaFin,
    required this.estado,
  });

  factory NovedadModel.fromJson(Map<String, dynamic> json) => NovedadModel(
        idEmpleado: json['id_empleado'] as int?,
        fechaNovedad: (json['Fecha_Novedad'] as String?)?.split('T').first,
        fechaRealizacion:
            (json['FechaRealizacion'] as String?)?.split('T').first,
        horaInicio: json['HoraInicio'] as String?,
        horaFin: json['HoraFin'] as String?,
        estado: json['Estado'] != 0 && json['Estado'] != false,
      );

  bool get esDiaCompleto =>
      (horaInicio == null || horaInicio!.isEmpty) &&
      (horaFin == null || horaFin!.isEmpty);

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

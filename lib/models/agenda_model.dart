class AgendaModel {
  final int idAgenda;
  final String fechaAgendamiento;
  final String hora;
  final int estado;
  final String? descripcion;
  final String cliente;
  final String vehiculo;
  final String empleado;
  final int? ordenId;

  const AgendaModel({
    required this.idAgenda,
    required this.fechaAgendamiento,
    required this.hora,
    required this.estado,
    this.descripcion,
    required this.cliente,
    required this.vehiculo,
    required this.empleado,
    this.ordenId,
  });

  factory AgendaModel.fromJson(Map<String, dynamic> json) => AgendaModel(
        idAgenda: (json['Id_Agenda'] ?? 0) as int,
        fechaAgendamiento: (json['FechaAgendamiento'] ?? '') as String,
        hora: (json['Hora'] ?? '') as String,
        estado: (json['Estado'] ?? 0) as int,
        descripcion: json['Descripcion'] as String?,
        cliente: (json['cliente'] ?? '') as String,
        vehiculo: (json['vehiculo'] ?? '') as String,
        empleado: (json['empleado'] ?? '') as String,
        ordenId: json['ordenId'] as int?,
      );
}

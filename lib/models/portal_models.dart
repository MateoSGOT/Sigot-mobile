int _int(dynamic v) =>
    v is int ? v : (v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0);
String _str(dynamic v) => v?.toString() ?? '';

/// Orden de trabajo vista desde el portal del cliente (Estado numérico 0..3).
class PortalOrden {
  final int idOrden;
  final int idVehiculo;
  final String vehiculo;
  final String? diagnostico;
  final String? fechaIngreso;
  final String? fechaEntrega;
  final int estado;

  const PortalOrden({
    required this.idOrden,
    required this.idVehiculo,
    required this.vehiculo,
    this.diagnostico,
    this.fechaIngreso,
    this.fechaEntrega,
    required this.estado,
  });

  String get estadoLabel => switch (estado) {
        0 => 'Inactivo',
        1 => 'Pendiente',
        2 => 'En proceso',
        3 => 'Realizado',
        _ => 'Pendiente',
      };

  factory PortalOrden.fromJson(Map<String, dynamic> json) => PortalOrden(
        idOrden: _int(json['Id_Orden']),
        idVehiculo: _int(json['Id_Vehiculo']),
        vehiculo: _str(json['Vehiculo'] ?? json['vehiculo']),
        diagnostico: (json['Diagnostico'] ?? json['diagnostico'])?.toString(),
        fechaIngreso: (json['FechaIngreso'])?.toString(),
        fechaEntrega: (json['FechaEntrega'])?.toString(),
        estado: _int(json['Estado']),
      );
}

/// Cita vista desde el portal del cliente.
class PortalCita {
  final int idAgenda;
  final String? fecha;
  final String hora;
  final String vehiculoPlaca;
  final String empleadoNombre;
  final String? descripcion;
  final String estadoCita;

  const PortalCita({
    required this.idAgenda,
    this.fecha,
    required this.hora,
    required this.vehiculoPlaca,
    required this.empleadoNombre,
    this.descripcion,
    required this.estadoCita,
  });

  factory PortalCita.fromJson(Map<String, dynamic> json) {
    final veh = json['vehiculo'];
    final emp = json['empleado'];
    return PortalCita(
      idAgenda: _int(json['Id_Agenda'] ?? json['id']),
      fecha: (json['FechaAgendamiento'])?.toString(),
      hora: _str(json['Hora']),
      vehiculoPlaca: veh is Map ? _str(veh['Placa']) : _str(json['VehiculoPlaca']),
      empleadoNombre: emp is Map
          ? _str(emp['Nombre'])
          : _str(json['EmpleadoNombre']).isEmpty
              ? 'Sin asignar'
              : _str(json['EmpleadoNombre']),
      descripcion: (json['Descripcion'])?.toString(),
      estadoCita: _str(json['EstadoCita']).isEmpty
          ? 'Pendiente'
          : _str(json['EstadoCita']),
    );
  }
}

/// Mecánico/técnico disponible para agendar, según
/// GET /api/portal/empleados-disponibles?fecha=... (el backend ya filtra
/// por rol Mecánico/Técnico y por novedades del día).
class EmpleadoDisponible {
  final int idEmpleado;
  final String nombre;
  final String rol;
  final bool disponible;

  const EmpleadoDisponible({
    required this.idEmpleado,
    required this.nombre,
    required this.rol,
    required this.disponible,
  });

  factory EmpleadoDisponible.fromJson(Map<String, dynamic> json) =>
      EmpleadoDisponible(
        idEmpleado: _int(json['id_empleado']),
        nombre: _str(json['Nombre']),
        rol: _str(json['Rol']),
        disponible: json['disponible'] as bool? ?? true,
      );
}

class EmpleadoModel {
  final int idEmpleado;
  final String nombre;
  final int idRol;
  final String rol;

  const EmpleadoModel({
    required this.idEmpleado,
    required this.nombre,
    required this.idRol,
    required this.rol,
  });

  factory EmpleadoModel.fromJson(Map<String, dynamic> json) => EmpleadoModel(
        idEmpleado: (json['id_empleado'] ?? json['Id_Empleado'] ?? 0) as int,
        nombre: (json['Nombre'] ?? '') as String,
        idRol: (json['Id_Rol'] ?? 0) as int,
        rol: (json['Rol'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'id_empleado': idEmpleado,
        'Nombre': nombre,
        'Id_Rol': idRol,
        'Rol': rol,
      };
}

/// Cliente del taller (para el panel del cliente / portal).
class ClienteModel {
  final int idCliente;
  final String nombre;
  final String? tipoDocumento;
  final String? documento;
  final String? correo;
  final String? telefono;
  final String? foto;

  const ClienteModel({
    required this.idCliente,
    required this.nombre,
    this.tipoDocumento,
    this.documento,
    this.correo,
    this.telefono,
    this.foto,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) => ClienteModel(
        idCliente: (json['Id_Cliente'] ?? 0) as int,
        nombre: (json['Nombre'] ?? '') as String,
        tipoDocumento: json['TipoDocumento'] as String?,
        documento: (json['Documento'])?.toString(),
        correo: json['Correo'] as String?,
        telefono: (json['Telefono'] ?? json['Contacto'])?.toString(),
        foto: (json['Foto'] ?? json['Foto_url']) as String?,
      );

  Map<String, dynamic> toJson() => {
        'Id_Cliente': idCliente,
        'Nombre': nombre,
        'TipoDocumento': tipoDocumento,
        'Documento': documento,
        'Correo': correo,
        'Telefono': telefono,
        'Foto': foto,
      };
}

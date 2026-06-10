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

class ServicioOrden {
  final String servicio;
  final double precioUnitario;
  final double subtotal;

  const ServicioOrden({
    required this.servicio,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory ServicioOrden.fromJson(Map<String, dynamic> json) => ServicioOrden(
        servicio: (json['servicio'] ?? '') as String,
        precioUnitario:
            ((json['precio_unitario'] ?? 0) as num).toDouble(),
        subtotal: ((json['subtotal'] ?? 0) as num).toDouble(),
      );
}

class RepuestoOrden {
  final String repuesto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const RepuestoOrden({
    required this.repuesto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory RepuestoOrden.fromJson(Map<String, dynamic> json) => RepuestoOrden(
        repuesto: (json['repuesto'] ?? '') as String,
        cantidad: (json['cantidad'] ?? 0) as int,
        precioUnitario:
            ((json['precio_unitario'] ?? 0) as num).toDouble(),
        subtotal: ((json['subtotal'] ?? 0) as num).toDouble(),
      );
}

class OrdenModel {
  final int idOrden;
  final String? diagnostico;
  final int? kilometraje;
  final String? fechaIngreso;
  final String? fechaEntrega;
  final int estado;
  final String estadoFlujo;
  final double? manoDeObra;
  final String cliente;
  final String vehiculo;
  final String empleado;
  final List<ServicioOrden> servicios;
  final List<RepuestoOrden> repuestos;

  const OrdenModel({
    required this.idOrden,
    this.diagnostico,
    this.kilometraje,
    this.fechaIngreso,
    this.fechaEntrega,
    required this.estado,
    required this.estadoFlujo,
    this.manoDeObra,
    required this.cliente,
    required this.vehiculo,
    required this.empleado,
    this.servicios = const [],
    this.repuestos = const [],
  });

  factory OrdenModel.fromJson(Map<String, dynamic> json) => OrdenModel(
        idOrden: (json['Id_Orden'] ?? 0) as int,
        diagnostico: json['Diagnostico'] as String?,
        kilometraje: json['Kilometraje'] as int?,
        fechaIngreso: json['FechaIngreso'] as String?,
        fechaEntrega: json['FechaEntrega'] as String?,
        estado: (json['Estado'] ?? 0) as int,
        estadoFlujo: (json['EstadoFlujo'] ?? 'Pendiente') as String,
        manoDeObra: json['mano_de_obra'] != null
            ? (json['mano_de_obra'] as num).toDouble()
            : null,
        cliente: (json['Cliente'] ?? '') as String,
        vehiculo: (json['Vehiculo'] ?? '') as String,
        empleado: (json['Empleado'] ?? '') as String,
        servicios: json['servicios'] != null
            ? (json['servicios'] as List)
                .map((s) => ServicioOrden.fromJson(s as Map<String, dynamic>))
                .toList()
            : const [],
        repuestos: json['repuestos'] != null
            ? (json['repuestos'] as List)
                .map((r) => RepuestoOrden.fromJson(r as Map<String, dynamic>))
                .toList()
            : const [],
      );
}

class ClienteCatalogo {
  final int idCliente;
  final String nombre;
  final String documento;

  const ClienteCatalogo({
    required this.idCliente,
    required this.nombre,
    required this.documento,
  });

  factory ClienteCatalogo.fromJson(Map<String, dynamic> json) =>
      ClienteCatalogo(
        idCliente: (json['Id_Cliente'] ?? 0) as int,
        nombre: (json['Nombre'] ?? '') as String,
        documento: (json['Documento'] ?? '') as String,
      );
}

class CompraModel {
  final int idCompra;
  final int idProveedor;
  final String proveedor;
  final int idRepuesto;
  final String repuesto;
  final int cantidad;
  final double precioUnitario;
  final String? fecha;
  final bool anulada;

  const CompraModel({
    required this.idCompra,
    required this.idProveedor,
    required this.proveedor,
    required this.idRepuesto,
    required this.repuesto,
    required this.cantidad,
    required this.precioUnitario,
    this.fecha,
    required this.anulada,
  });

  double get total => cantidad * precioUnitario;

  factory CompraModel.fromJson(Map<String, dynamic> json) => CompraModel(
        idCompra: (json['Id_Compra'] ?? 0) as int,
        idProveedor: (json['Id_Proveedor'] ?? 0) as int,
        proveedor: (json['Proveedor'] ?? '') as String,
        idRepuesto: (json['Id_Repuesto'] ?? 0) as int,
        repuesto: (json['Repuesto'] ?? '') as String,
        cantidad: (json['Cantidad'] ?? 0) as int,
        precioUnitario: ((json['PrecioUnitario'] ?? 0) as num).toDouble(),
        fecha: json['Fecha'] as String?,
        // La web trata Anulada como booleano (puede venir 1/0/true/false).
        anulada: json['Anulada'] == true || json['Anulada'] == 1,
      );
}

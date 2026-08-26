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
        idCompra: _int(json['Id_Compra']),
        idProveedor: _int(json['Id_Proveedor']),
        proveedor: _str(json['Proveedor'] ?? json['proveedor']),
        idRepuesto: _int(json['Id_Repuesto']),
        repuesto: _str(json['Repuesto'] ?? json['repuesto']),
        cantidad: _int(json['Cantidad'] ?? json['cantidad']),
        precioUnitario:
            _double(json['PrecioUnitario'] ?? json['precioUnitario']),
        fecha: (json['Fecha'] ?? json['fecha'])?.toString(),
        // Anulada puede venir como bool, 1/0 o "1"/"0".
        anulada: _bool(json['Anulada'] ?? json['anulada']),
      );
}

// Parsers tolerantes: los backends suelen enviar números como texto
// (p. ej. decimales "18000.00") o el estado como 1/0/"true".
int _int(dynamic v) =>
    v is int ? v : (v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0);

double _double(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

String _str(dynamic v) => v?.toString() ?? '';

bool _bool(dynamic v) =>
    v == true || v == 1 || v == '1' || v?.toString().toLowerCase() == 'true';

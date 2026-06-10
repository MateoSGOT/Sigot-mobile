class VehiculoModel {
  final int idVehiculo;
  final String placa;
  final String? vin;
  final String modelo;
  final int anio;
  final String? color;
  final int estado;
  final String cliente;
  final String marca;

  const VehiculoModel({
    required this.idVehiculo,
    required this.placa,
    this.vin,
    required this.modelo,
    required this.anio,
    this.color,
    required this.estado,
    required this.cliente,
    required this.marca,
  });

  factory VehiculoModel.fromJson(Map<String, dynamic> json) => VehiculoModel(
        idVehiculo: (json['Id_Vehiculo'] ?? 0) as int,
        placa: (json['Placa'] ?? '') as String,
        vin: json['VIN'] as String?,
        modelo: (json['Modelo'] ?? '') as String,
        anio: (json['Anio'] ?? 0) as int,
        color: json['Color'] as String?,
        estado: (json['Estado'] ?? 0) as int,
        cliente: (json['Cliente'] ?? '') as String,
        marca: (json['Marca'] ?? '') as String,
      );
}

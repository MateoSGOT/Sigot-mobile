import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/vehiculo_model.dart';
import '../../providers/orden_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/estado_badge.dart';
import '../../widgets/orden_card.dart';
import '../../widgets/loading_widget.dart';
import '../ordenes/orden_detail_screen.dart';

class VehiculoDetailScreen extends StatefulWidget {
  final VehiculoModel vehiculo;

  const VehiculoDetailScreen({super.key, required this.vehiculo});

  @override
  State<VehiculoDetailScreen> createState() => _VehiculoDetailScreenState();
}

class _VehiculoDetailScreenState extends State<VehiculoDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehiculo;
    return Scaffold(
      appBar: AppBar(title: Text(v.placa)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppColors.paddingStd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppColors.paddingStd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_car,
                            color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          v.placa,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        EstadoBadge(
                            estado:
                                v.estado == 1 ? 'Realizado' : 'Inactivo'),
                      ],
                    ),
                    const Divider(height: 20),
                    _field('Marca', v.marca),
                    _field('Modelo', v.modelo),
                    _field('Año', v.anio.toString()),
                    if (v.color != null && v.color!.isNotEmpty)
                      _field('Color', v.color!),
                    if (v.vin != null && v.vin!.isNotEmpty)
                      _field('VIN', v.vin!),
                    _field('Cliente', v.cliente),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Historial de órdenes',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            _buildOrdenes(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdenes() {
    final prov = context.watch<OrdenProvider>();
    if (prov.state == LoadState.loading) return const LoadingWidget();
    final ordenes = prov.filtered
        .where((o) => o.vehiculo == widget.vehiculo.placa)
        .toList();
    if (ordenes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Sin órdenes para este vehículo',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return Column(
      children: ordenes
          .map((o) => OrdenCard(
                orden: o,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrdenDetailScreen(idOrden: o.idOrden),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}

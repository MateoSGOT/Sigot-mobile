import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/vehiculo_model.dart';
import '../../providers/orden_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/detail_ui.dart';
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
    final activo = v.estado == 1;
    return Scaffold(
      appBar: AppBar(title: Text(v.placa)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DetailHero(
            icon: Icons.directions_car,
            title: v.placa,
            subtitle: '${v.marca} ${v.modelo} ${v.anio}',
            badge: _badge(
              activo ? 'Activo' : 'Inactivo',
              activo ? AppColors.badgeRealizado : AppColors.badgeInactivo,
            ),
          ),
          DetailGroup(
            title: 'Datos del vehículo',
            children: [
              DetailTile(
                  icon: Icons.branding_watermark_outlined,
                  label: 'Marca',
                  value: v.marca),
              DetailTile(
                  icon: Icons.directions_car_outlined,
                  label: 'Modelo',
                  value: v.modelo),
              DetailTile(
                  icon: Icons.event, label: 'Año', value: v.anio.toString()),
              if (v.color != null && v.color!.isNotEmpty)
                DetailTile(
                    icon: Icons.color_lens, label: 'Color', value: v.color!),
              if (v.vin != null && v.vin!.isNotEmpty)
                DetailTile(
                    icon: Icons.tag, label: 'VIN', value: v.vin!),
              DetailTile(
                  icon: Icons.person, label: 'Cliente', value: v.cliente),
            ],
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 6, 20, 8),
            child: Text(
              'Historial de órdenes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildOrdenes(),
        ],
      ),
    );
  }

  Widget _buildOrdenes() {
    final prov = context.watch<OrdenProvider>();
    if (prov.state == LoadState.loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: LoadingWidget(),
      );
    }
    final ordenes = prov.all
        .where((o) => o.vehiculo == widget.vehiculo.placa)
        .toList();
    if (ordenes.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 22),
            SizedBox(width: 10),
            Text('Sin órdenes para este vehículo',
                style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < ordenes.length; i++)
          AnimatedEntrance(
            index: i,
            child: OrdenCard(
              orden: ordenes[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      OrdenDetailScreen(idOrden: ordenes[i].idOrden),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

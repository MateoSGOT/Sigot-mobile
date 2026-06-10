import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/orden_model.dart';
import '../../providers/orden_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/estado_badge.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class OrdenDetailScreen extends StatefulWidget {
  final int idOrden;

  const OrdenDetailScreen({super.key, required this.idOrden});

  @override
  State<OrdenDetailScreen> createState() => _OrdenDetailScreenState();
}

class _OrdenDetailScreenState extends State<OrdenDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenProvider>().loadDetalle(widget.idOrden);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  String _formatFecha(String? fecha) {
    if (fecha == null) return '—';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(fecha));
    } catch (_) {
      return fecha;
    }
  }

  String _formatMoney(double? v) {
    if (v == null) return '\$0';
    return NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0)
        .format(v);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OrdenProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Orden #${widget.idOrden}')),
      body: switch (prov.detalleState) {
        LoadState.loading => const LoadingWidget(),
        LoadState.error => EmptyStateWidget(
            icon: Icons.error_outline,
            message: prov.error ?? 'Error al cargar detalle',
            onRetry: () => prov.loadDetalle(widget.idOrden),
            retryLabel: 'Reintentar',
          ),
        _ => _buildContent(prov),
      },
    );
  }

  Widget _buildContent(OrdenProvider prov) {
    final o = prov.detalle;
    if (o == null) return const SizedBox();

    final subServ = o.servicios.fold(0.0, (s, e) => s + e.subtotal);
    final subRep = o.repuestos.fold(0.0, (s, e) => s + e.subtotal);
    final total = subServ + subRep + (o.manoDeObra ?? 0);

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(AppColors.paddingStd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Orden #${o.idOrden}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    EstadoBadge(estado: o.estadoFlujo),
                  ],
                ),
                const Divider(height: 16),
                _field('Cliente', o.cliente),
                _field('Vehículo', o.vehiculo),
                _field('Empleado', o.empleado),
                _field('F. Ingreso', _formatFecha(o.fechaIngreso)),
                _field('F. Entrega', _formatFecha(o.fechaEntrega)),
                if (o.kilometraje != null)
                  _field('Km', '${o.kilometraje} km'),
              ],
            ),
          ),
        ),
        TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Servicios'),
            Tab(text: 'Repuestos'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _tabInfo(o),
              _tabServicios(o.servicios),
              _tabRepuestos(o.repuestos),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppColors.paddingStd),
          color: AppColors.surface,
          child: Column(
            children: [
              const Divider(),
              _totalRow('Subtotal servicios', subServ),
              _totalRow('Subtotal repuestos', subRep),
              _totalRow('Mano de obra', o.manoDeObra ?? 0),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary)),
                  Text(
                    _formatMoney(total),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabInfo(OrdenModel o) => ListView(
        padding: const EdgeInsets.all(AppColors.paddingStd),
        children: [
          const Text('Diagnóstico',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            o.diagnostico ?? 'Sin diagnóstico',
            style: const TextStyle(
                fontSize: 15, color: AppColors.textPrimary, height: 1.5),
          ),
          const SizedBox(height: 16),
          _field('Estado', o.estadoFlujo),
          if (o.kilometraje != null)
            _field('Kilometraje', '${o.kilometraje} km'),
        ],
      );

  Widget _tabServicios(List servicios) {
    if (servicios.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.build_outlined,
        message: 'Sin servicios registrados',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppColors.paddingStd),
      itemCount: servicios.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final s = servicios[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(s.servicio,
                    style: const TextStyle(color: AppColors.textPrimary)),
              ),
              Text(
                _formatMoney(s.subtotal),
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabRepuestos(List repuestos) {
    if (repuestos.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.settings_outlined,
        message: 'Sin repuestos registrados',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppColors.paddingStd),
      itemCount: repuestos.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final r = repuestos[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.repuesto,
                        style: const TextStyle(
                            color: AppColors.textPrimary)),
                    Text('x${r.cantidad}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                _formatMoney(r.subtotal),
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14)),
            ),
          ],
        ),
      );

  Widget _totalRow(String label, double value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
            Text(_formatMoney(value),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13)),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/orden_model.dart';
import '../../providers/orden_provider.dart';
import '../../services/api_service.dart';
import '../../utils/format.dart';
import '../../widgets/estado_badge.dart';
import '../../widgets/detail_ui.dart';
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
        DetailHero(
          icon: Icons.assignment,
          title: 'Orden #${o.idOrden}',
          subtitle: o.vehiculo,
          badge: EstadoBadge(estado: o.estadoFlujo),
        ),
        _buildTabs(),
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
        _buildTotals(subServ, subRep, o.manoDeObra ?? 0, total),
      ],
    );
  }

  Widget _buildTabs() => Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicator: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(9),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.primaryStrong,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle:
              const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13.5),
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Servicios'),
            Tab(text: 'Repuestos'),
          ],
        ),
      );

  Widget _tabInfo(OrdenModel o) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDeco(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Diagnóstico',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        fontSize: 12,
                        letterSpacing: 0.6)),
                const SizedBox(height: 6),
                Text(
                  o.diagnostico?.isNotEmpty == true
                      ? o.diagnostico!
                      : 'Sin diagnóstico',
                  style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DetailGroup(
            children: [
              DetailTile(
                  icon: Icons.person, label: 'Cliente', value: o.cliente),
              DetailTile(
                  icon: Icons.directions_car,
                  label: 'Vehículo',
                  value: o.vehiculo),
              DetailTile(
                  icon: Icons.badge_outlined,
                  label: 'Empleado',
                  value: o.empleado),
              DetailTile(
                  icon: Icons.login,
                  label: 'Fecha de ingreso',
                  value: formatDate(o.fechaIngreso)),
              DetailTile(
                  icon: Icons.logout,
                  label: 'Fecha de entrega',
                  value: formatDate(o.fechaEntrega)),
              if (o.kilometraje != null)
                DetailTile(
                    icon: Icons.speed,
                    label: 'Kilometraje',
                    value: '${o.kilometraje} km'),
            ],
          ),
        ],
      );

  Widget _tabServicios(List<ServicioOrden> servicios) {
    if (servicios.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.build_outlined,
        message: 'Sin servicios registrados',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: servicios.length,
      itemBuilder: (_, i) => AnimatedEntrance(
        index: i,
        child: _lineItem(
          icon: Icons.build,
          title: servicios[i].servicio,
          subtitle: null,
          amount: formatCurrency(servicios[i].subtotal),
        ),
      ),
    );
  }

  Widget _tabRepuestos(List<RepuestoOrden> repuestos) {
    if (repuestos.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.settings_outlined,
        message: 'Sin repuestos registrados',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: repuestos.length,
      itemBuilder: (_, i) => AnimatedEntrance(
        index: i,
        child: _lineItem(
          icon: Icons.settings,
          title: repuestos[i].repuesto,
          subtitle: 'x${repuestos[i].cantidad}',
          amount: formatCurrency(repuestos[i].subtotal),
        ),
      ),
    );
  }

  Widget _lineItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required String amount,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: _cardDeco(),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Text(amount,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
      );

  Widget _buildTotals(
          double subServ, double subRep, double mano, double total) =>
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _totalRow('Subtotal servicios', subServ),
              _totalRow('Subtotal repuestos', subRep),
              _totalRow('Mano de obra', mano),
              Divider(color: Colors.black.withValues(alpha: 0.08)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.5,
                          color: AppColors.textPrimary)),
                  Text(
                    formatCurrency(total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: AppColors.primaryStrong),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  BoxDecoration _cardDeco() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );

  Widget _totalRow(String label, double value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
            Text(formatCurrency(value),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13)),
          ],
        ),
      );
}

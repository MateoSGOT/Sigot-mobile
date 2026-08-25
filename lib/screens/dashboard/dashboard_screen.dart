import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/api_service.dart';
import '../../utils/format.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/mini_area_chart.dart';
import '../../widgets/empty_state_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<DashboardProvider>();
      if (p.state == LoadState.idle) p.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DashboardProvider>();
    final loading = p.state == LoadState.loading;

    return Column(
      children: [
        const SizedBox(height: 4),
        SigotFilterChips(
          labels: DashboardProvider.presetLabels,
          selected: p.presetIndex,
          onSelected: (i) => p.setPreset(DashboardProvider.presets[i]),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: p.state == LoadState.error
              ? EmptyStateWidget(
                  icon: Icons.error_outline,
                  message: p.error ?? 'Error al cargar el dashboard',
                  onRetry: p.load,
                  retryLabel: 'Reintentar',
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: p.load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    children: [
                      _kpiGrid(p, loading),
                      if (!loading && p.resumen.stockBajo > 0) ...[
                        const SizedBox(height: 12),
                        _stockAlert(p),
                      ],
                      const SizedBox(height: 16),
                      _ingresosCard(p, loading),
                      const SizedBox(height: 16),
                      _topServiciosCard(p, loading),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _kpiGrid(DashboardProvider p, bool loading) {
    final r = p.resumen;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.payments,
                label: 'Ingreso del rango',
                value: formatCurrency(r.ingresoTotal),
                sub: 'Órdenes entregadas',
                color: AppColors.primaryStrong,
                loading: loading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.receipt_long,
                label: 'Órdenes realizadas',
                value: '${r.ordenesRealizadas}',
                sub: 'En el rango',
                color: AppColors.infoStrong,
                loading: loading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.confirmation_number,
                label: 'Ticket promedio',
                value: formatCurrency(r.ticketPromedio),
                sub: 'Por orden',
                color: AppColors.badgePendiente,
                loading: loading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.inventory_2,
                label: 'Stock bajo',
                value: '${r.stockBajo}',
                sub: r.stockCritico > 0
                    ? '${r.stockCritico} agotado(s)'
                    : 'Repuestos',
                color: const Color(0xFF7C3AED),
                loading: loading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stockAlert(DashboardProvider p) {
    final critico = p.resumen.stockCritico > 0;
    final color = critico ? AppColors.error : AppColors.badgePendiente;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${p.resumen.stockBajo} repuesto(s) con stock bajo'
              '${critico ? ' · ${p.resumen.stockCritico} agotado(s)' : ''}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: critico ? AppColors.dangerStrong : const Color(0xFFb45309),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
              child: child,
            ),
          ],
        ),
      );

  Widget _ingresosCard(DashboardProvider p, bool loading) {
    final values = p.ingresos.series.map((e) => e.total).toList();
    return _card(
      title: 'Ingresos · ${formatCurrency(p.ingresos.total)}',
      child: loading
          ? const SizedBox(
              height: 160,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : values.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Aún no hay ingresos en el rango',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                )
              : MiniAreaChart(values: values),
    );
  }

  Widget _topServiciosCard(DashboardProvider p, bool loading) {
    final items = p.topServicios;
    final maxV = items.isEmpty
        ? 1
        : items.map((e) => e.veces).reduce((a, b) => a > b ? a : b);
    return _card(
      title: 'Servicios más realizados',
      child: loading
          ? const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      'Sin datos suficientes',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final s in items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                s.nombre,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: (s.veces / maxV).clamp(0.05, 1.0),
                                  minHeight: 8,
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.10),
                                  valueColor: const AlwaysStoppedAnimation(
                                      AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${s.veces}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}

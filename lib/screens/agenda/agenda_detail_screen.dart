import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/agenda_model.dart';
import '../../providers/agenda_provider.dart';
import '../../widgets/detail_ui.dart';
import '../ordenes/orden_detail_screen.dart';

class AgendaDetailScreen extends StatelessWidget {
  final AgendaModel agenda;

  const AgendaDetailScreen({super.key, required this.agenda});

  String _formatFecha(String fecha) {
    try {
      return DateFormat('dd MMMM yyyy', 'es').format(DateTime.parse(fecha));
    } catch (_) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final realizado = agenda.estado == 1;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de cita')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DetailHero(
            icon: Icons.event_available,
            title: 'Cita',
            subtitle:
                '${_formatFecha(agenda.fechaAgendamiento)} · ${agenda.hora}',
            badge: _badge(realizado ? 'Realizado' : 'Pendiente',
                realizado ? AppColors.badgeRealizado : AppColors.badgePendiente),
          ),
          DetailGroup(
            title: 'Información',
            children: [
              DetailTile(
                  icon: Icons.calendar_today,
                  label: 'Fecha',
                  value: _formatFecha(agenda.fechaAgendamiento)),
              DetailTile(
                  icon: Icons.schedule, label: 'Hora', value: agenda.hora),
              DetailTile(
                  icon: Icons.person, label: 'Cliente', value: agenda.cliente),
              DetailTile(
                  icon: Icons.directions_car,
                  label: 'Vehículo',
                  value: agenda.vehiculo),
              DetailTile(
                  icon: Icons.badge_outlined,
                  label: 'Empleado',
                  value: agenda.empleado),
              if (agenda.descripcion != null &&
                  agenda.descripcion!.isNotEmpty)
                DetailTile(
                    icon: Icons.description,
                    label: 'Descripción',
                    value: agenda.descripcion!),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: agenda.ordenId == null
                ? _generarOrdenButton(context)
                : _verOrdenButton(context),
          ),
        ],
      ),
    );
  }

  Widget _generarOrdenButton(BuildContext context) =>
      Consumer<AgendaProvider>(
        builder: (ctx, prov, _) => _GradientButton(
          icon: Icons.post_add,
          label: 'Generar orden',
          onTap: () async {
            final ok = await prov.generarOrden(agenda.idAgenda);
            if (!ctx.mounted) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(ok
                    ? 'Orden generada exitosamente'
                    : prov.error ?? 'Error al generar orden'),
                backgroundColor: ok ? AppColors.primary : AppColors.error,
              ),
            );
            if (ok) Navigator.pop(ctx);
          },
        ),
      );

  // El botón "Ver orden" abre la orden de trabajo asociada (fix del equipo,
  // conservado sobre el nuevo diseño).
  Widget _verOrdenButton(BuildContext context) => Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrdenDetailScreen(idOrden: agenda.ordenId!),
              ),
            ),
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment,
                      color: AppColors.primaryStrong, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Ver orden #${agenda.ordenId}',
                    style: const TextStyle(
                        color: AppColors.primaryStrong,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

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

/// Botón esmeralda con degradado, icono y ripple.
class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GradientButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppBrand.buttonEmerald,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.32),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

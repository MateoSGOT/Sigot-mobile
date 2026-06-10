import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/agenda_model.dart';
import '../../providers/agenda_provider.dart';
import '../../widgets/estado_badge.dart';

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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Detalle de cita')),
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
                          const Text(
                            'Cita',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 8),
                          EstadoBadge(
                              estado: agenda.estado == 1
                                  ? 'Realizado'
                                  : 'Pendiente'),
                        ],
                      ),
                      const Divider(height: 20),
                      _field('Fecha', _formatFecha(agenda.fechaAgendamiento)),
                      _field('Hora', agenda.hora),
                      _field('Cliente', agenda.cliente),
                      _field('Vehículo', agenda.vehiculo),
                      _field('Empleado', agenda.empleado),
                      if (agenda.descripcion != null &&
                          agenda.descripcion!.isNotEmpty)
                        _field('Descripción', agenda.descripcion!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (agenda.ordenId == null)
                Consumer<AgendaProvider>(
                  builder: (ctx, prov, _) => ElevatedButton.icon(
                    icon: const Icon(Icons.assignment_add),
                    label: const Text('Generar orden'),
                    onPressed: () async {
                      final ok =
                          await prov.generarOrden(agenda.idAgenda);
                      if (!ctx.mounted) return;
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Orden generada exitosamente'
                              : prov.error ?? 'Error al generar orden'),
                          backgroundColor:
                              ok ? AppColors.primary : AppColors.error,
                        ),
                      );
                      if (ok) Navigator.pop(ctx);
                    },
                  ),
                )
              else
                OutlinedButton.icon(
                  icon: const Icon(Icons.assignment),
                  label: Text('Ver orden #${agenda.ordenId}'),
                  onPressed: () {},
                ),
            ],
          ),
        ),
      );

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/agenda_model.dart';
import '../config/app_theme.dart';
import 'estado_badge.dart';

class AgendaCard extends StatelessWidget {
  final AgendaModel agenda;
  final VoidCallback onTap;
  final VoidCallback? onVerOrden;

  const AgendaCard({
    super.key,
    required this.agenda,
    required this.onTap,
    this.onVerOrden,
  });

  String _formatFecha(String fecha) {
    try {
      final d = DateTime.parse(fecha);
      return DateFormat('dd MMM yyyy', 'es').format(d);
    } catch (_) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppColors.paddingStd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatFecha(agenda.fechaAgendamiento)}  •  ${agenda.hora}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                _row(Icons.person, agenda.cliente),
                const SizedBox(height: 6),
                _row(Icons.directions_car, agenda.vehiculo),
                if (agenda.descripcion != null &&
                    agenda.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _row(Icons.description, agenda.descripcion!),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    EstadoBadge(
                        estado: agenda.estado == 1 ? 'Realizado' : 'Pendiente'),
                    if (agenda.ordenId != null)
                      TextButton(
                        onPressed: onVerOrden,
                        child: const Text('Ver orden →'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}

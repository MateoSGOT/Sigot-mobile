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
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          border: const Border(
            left: BorderSide(color: AppColors.primary, width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
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
                        EstadoBadge(estado: agenda.estadoCita),
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

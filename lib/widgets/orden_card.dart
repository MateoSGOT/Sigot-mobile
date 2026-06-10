import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/orden_model.dart';
import '../config/app_theme.dart';
import 'estado_badge.dart';

class OrdenCard extends StatelessWidget {
  final OrdenModel orden;
  final VoidCallback onTap;

  const OrdenCard({super.key, required this.orden, required this.onTap});

  Color _borderColor() => switch (orden.estadoFlujo) {
        'Pendiente' => AppColors.badgePendiente,
        'En proceso' => AppColors.badgeEnProceso,
        'Realizado' => AppColors.badgeRealizado,
        _ => AppColors.badgeInactivo,
      };

  String _formatFecha(String? fecha) {
    if (fecha == null) return '—';
    try {
      final d = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          side: BorderSide.none,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 5, color: _borderColor()),
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(AppColors.paddingStd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Orden #${orden.idOrden}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              EstadoBadge(estado: orden.estadoFlujo),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _row(Icons.directions_car, orden.vehiculo),
                          const SizedBox(height: 4),
                          _row(Icons.person, orden.cliente),
                          const SizedBox(height: 4),
                          _row(Icons.calendar_today,
                              _formatFecha(orden.fechaIngreso)),
                          if (orden.diagnostico != null &&
                              orden.diagnostico!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              orden.diagnostico!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: onTap,
                              child: const Text('Ver detalle →'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}

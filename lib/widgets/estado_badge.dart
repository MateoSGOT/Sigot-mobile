import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class EstadoBadge extends StatelessWidget {
  final String estado;

  const EstadoBadge({super.key, required this.estado});

  Color _color() => switch (estado) {
        'Pendiente' => AppColors.badgePendiente,
        'Confirmada' => AppColors.badgeEnProceso,
        'En proceso' => AppColors.badgeEnProceso,
        'Realizado' => AppColors.badgeRealizado,
        'Atendida' => AppColors.badgeRealizado,
        'Cancelada' => AppColors.badgeInactivo,
        'NoAsistio' => AppColors.badgeInactivo,
        _ => AppColors.badgeInactivo,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

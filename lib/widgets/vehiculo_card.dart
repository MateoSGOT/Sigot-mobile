import 'package:flutter/material.dart';
import '../models/vehiculo_model.dart';
import '../config/app_theme.dart';
import 'estado_badge.dart';

class VehiculoCard extends StatelessWidget {
  final VehiculoModel vehiculo;
  final VoidCallback onTap;

  const VehiculoCard({super.key, required this.vehiculo, required this.onTap});

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
                    const Icon(Icons.directions_car,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vehiculo.placa,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    EstadoBadge(
                        estado:
                            vehiculo.estado == 1 ? 'Realizado' : 'Inactivo'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${vehiculo.marca} ${vehiculo.modelo} ${vehiculo.anio}',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                _row(Icons.person, vehiculo.cliente),
                if (vehiculo.color != null && vehiculo.color!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _row(Icons.color_lens, vehiculo.color!),
                ],
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

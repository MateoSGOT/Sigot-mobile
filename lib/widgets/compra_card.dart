import 'package:flutter/material.dart';
import '../models/compra_model.dart';
import '../config/app_theme.dart';
import '../utils/format.dart';

class CompraCard extends StatelessWidget {
  final CompraModel compra;
  final VoidCallback onTap;

  const CompraCard({super.key, required this.compra, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final anulada = compra.anulada;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
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
                      const Icon(Icons.shopping_cart,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          compra.proveedor.isEmpty
                              ? 'Proveedor #${compra.idProveedor}'
                              : compra.proveedor,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _estadoBadge(anulada),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _row(Icons.build, compra.repuesto),
                  const SizedBox(height: 4),
                  _row(Icons.calendar_today, formatDate(compra.fecha)),
                  const Divider(height: 18),
                  Row(
                    children: [
                      Text(
                        '${compra.cantidad} × ${formatCurrency(compra.precioUnitario)}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMuted),
                      ),
                      const Spacer(),
                      Text(
                        formatCurrency(compra.total),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryStrong,
                        ),
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
  }

  Widget _estadoBadge(bool anulada) {
    final color = anulada ? AppColors.badgeInactivo : AppColors.badgeRealizado;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        anulada ? 'Anulada' : 'Vigente',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

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

import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/compra_model.dart';
import '../../utils/format.dart';

class CompraDetailScreen extends StatelessWidget {
  final CompraModel compra;

  const CompraDetailScreen({super.key, required this.compra});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Detalle de la compra')),
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
                          Text(
                            'Compra #${compra.idCompra}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _estadoBadge(compra.anulada),
                        ],
                      ),
                      const Divider(height: 20),
                      _field('Proveedor', compra.proveedor.isEmpty
                          ? 'Proveedor #${compra.idProveedor}'
                          : compra.proveedor),
                      _field('Repuesto', compra.repuesto),
                      _field('Cantidad', '${compra.cantidad}'),
                      _field('Precio unitario',
                          formatCurrency(compra.precioUnitario)),
                      _field('Fecha', formatDate(compra.fecha)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppColors.paddingStd),
                decoration: BoxDecoration(
                  gradient: AppBrand.buttonEmerald,
                  borderRadius: BorderRadius.circular(AppColors.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatCurrency(compra.total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

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
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
}

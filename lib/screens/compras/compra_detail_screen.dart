import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/compra_model.dart';
import '../../utils/format.dart';
import '../../widgets/detail_ui.dart';

class CompraDetailScreen extends StatelessWidget {
  final CompraModel compra;

  const CompraDetailScreen({super.key, required this.compra});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Detalle de la compra')),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            DetailHero(
              icon: Icons.shopping_cart,
              title: 'Compra #${compra.idCompra}',
              subtitle: compra.proveedor.isEmpty
                  ? 'Proveedor #${compra.idProveedor}'
                  : compra.proveedor,
              badge: _estadoBadge(compra.anulada),
            ),
            DetailGroup(
              title: 'Detalle',
              children: [
                DetailTile(
                    icon: Icons.build,
                    label: 'Repuesto',
                    value: compra.repuesto),
                DetailTile(
                    icon: Icons.inventory_2_outlined,
                    label: 'Cantidad',
                    value: '${compra.cantidad}'),
                DetailTile(
                    icon: Icons.sell_outlined,
                    label: 'Precio unitario',
                    value: formatCurrency(compra.precioUnitario)),
                DetailTile(
                    icon: Icons.calendar_today,
                    label: 'Fecha',
                    value: formatDate(compra.fecha)),
              ],
            ),
            const SizedBox(height: 8),
            _totalBanner(),
          ],
        ),
      );

  Widget _totalBanner() => Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          gradient: AppBrand.buttonEmerald,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.payments_outlined, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            const Text(
              'Total de la compra',
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
}

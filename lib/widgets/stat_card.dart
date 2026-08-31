import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Tarjeta de KPI del dashboard: chip de icono coloreado, valor grande (con
/// animación de conteo opcional) y subtítulo.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final num? animate; // valor numérico a animar (cuenta hacia arriba)
  final String Function(num)? format;
  final String? sub;
  final Color color;
  final bool loading;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.animate,
    this.format,
    this.sub,
    this.loading = false,
  });

  static const _valueStyle = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.16),
                    color.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 12),
            loading
                ? Container(
                    width: 84,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  )
                : (animate != null && format != null)
                    ? TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: animate!.toDouble()),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => Text(
                          format!(v),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _valueStyle,
                        ),
                      )
                    : Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _valueStyle,
                      ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(sub!, style: TextStyle(fontSize: 11, color: color)),
            ],
          ],
        ),
      );
}

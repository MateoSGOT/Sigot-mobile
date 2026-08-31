import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Encabezado "hero" de una pantalla de detalle: icono en píldora con degradado
/// esmeralda + título/subtítulo + badge de estado opcional.
class DetailHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? badge;

  const DetailHero({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.16),
                    AppBrand.green.withValues(alpha: 0.18),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryStrong, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                            fontSize: 13.5, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (badge != null) Padding(
              padding: const EdgeInsets.only(left: 8),
              child: badge!,
            ),
          ],
        ),
      );
}

/// Tarjeta blanca con un título opcional y filas de información separadas por
/// líneas sutiles.
class DetailGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const DetailGroup({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)));
      }
      rows.add(children[i]);
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 2, left: 2),
              child: Text(
                title!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ...rows,
        ],
      ),
    );
  }
}

/// Fila de información: icono + etiqueta encima del valor + trailing opcional.
class DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const DetailTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

/// Entrada animada (fade + subida) con retardo por índice, para escalonar la
/// aparición de las tarjetas de una lista.
class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedEntrance({super.key, required this.child, this.index = 0});

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    // Escalona el arranque según la posición (máximo ~240ms).
    final delay = (widget.index.clamp(0, 6)) * 45;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final v = Curves.easeOutCubic.transform(_c.value);
          return Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 14 * (1 - v)),
              child: child,
            ),
          );
        },
        child: widget.child,
      );
}

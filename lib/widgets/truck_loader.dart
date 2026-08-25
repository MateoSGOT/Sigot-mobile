import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Loader del splash: un camión "conduciendo" con ruedas que giran, humito que
/// sale por detrás y rebote sobre una carretera con líneas en movimiento.
/// Dibujado con `CustomPainter` (sin librerías). La altura del camión equivale
/// a `size`; el lienzo es un poco más ancho/alto para el humo y las ruedas.
class TruckLoader extends StatefulWidget {
  final double size;
  final Color color;

  const TruckLoader({super.key, this.size = 26, this.color = AppBrand.green});

  @override
  State<TruckLoader> createState() => _TruckLoaderState();
}

class _TruckLoaderState extends State<TruckLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s * 2.0,
      height: s * 1.45,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _TruckPainter(t: _c.value, unit: s, color: widget.color),
        ),
      ),
    );
  }
}

class _TruckPainter extends CustomPainter {
  final double t; // 0..1 continuo
  final double unit; // altura nominal del camión
  final Color color; // verde de marca

  static const Color _dark = Color(0xFF0E1A2C);
  static const Color _spoke = Color(0xFF94A3B8);

  _TruckPainter({required this.t, required this.unit, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final u = unit;
    final ground = h - 1.5;

    // ——— carretera: líneas que se desplazan a la izquierda ———
    final road = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dash = 6.0, gap = 5.0, period = dash + gap;
    final startX = -(t * period) % period;
    for (var x = startX; x < w; x += period) {
      canvas.drawLine(Offset(x, ground), Offset(x + dash, ground), road);
    }

    // rebote de conducción
    final bob = -(math.sin(t * 2 * math.pi)).abs() * (u * 0.07);
    canvas.save();
    canvas.translate(0, bob);

    // métricas del camión
    final wheelR = u * 0.15;
    final wheelY = ground - wheelR;
    final bodyBottom = wheelY - wheelR * 0.1;
    final bodyTop = bodyBottom - u * 0.6;
    final left = u * 0.5;
    final cargoW = u * 0.8;
    final cabLeft = left + cargoW;
    final cabRight = cabLeft + u * 0.48;
    final cabTop = bodyTop + u * 0.16;

    final green = Paint()..color = color;

    // ——— humito (sale por detrás, arriba-izquierda) ———
    for (var i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1;
      final r = u * (0.09 + 0.13 * phase);
      final sx = left - u * 0.40 * phase;
      final sy = bodyTop + u * 0.05 - u * 0.5 * phase;
      final op = (1 - phase) * 0.5;
      canvas.drawCircle(
          Offset(sx, sy), r, Paint()..color = Colors.white.withValues(alpha: op));
    }

    // ——— carrocería ———
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(left, bodyTop, cabLeft, bodyBottom),
          Radius.circular(u * 0.08)),
      green,
    );
    // ——— cabina ———
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(cabLeft, cabTop, cabRight, bodyBottom),
          Radius.circular(u * 0.08)),
      green,
    );
    // ventana
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(
              cabLeft + u * 0.08, cabTop + u * 0.06, cabRight - u * 0.06, cabTop + u * 0.26),
          Radius.circular(u * 0.05)),
      Paint()..color = _dark,
    );

    // ——— ruedas girando ———
    _wheel(canvas, Offset(left + cargoW * 0.32, wheelY), wheelR);
    _wheel(canvas, Offset(cabLeft + u * 0.26, wheelY), wheelR);

    canvas.restore();
  }

  void _wheel(Canvas canvas, Offset c, double r) {
    final angle = t * 2 * math.pi * 2; // 2 vueltas por ciclo
    canvas.drawCircle(c, r, Paint()..color = _dark); // neumático
    // radios giratorios (2 líneas cruzadas)
    final spoke = Paint()
      ..color = _spoke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var k = 0; k < 2; k++) {
      final a = angle + k * math.pi / 2;
      canvas.drawLine(
        Offset(c.dx + math.cos(a) * r * 0.55, c.dy + math.sin(a) * r * 0.55),
        Offset(c.dx - math.cos(a) * r * 0.55, c.dy - math.sin(a) * r * 0.55),
        spoke,
      );
    }
    canvas.drawCircle(c, r * 0.38, Paint()..color = Colors.white); // buje
  }

  @override
  bool shouldRepaint(covariant _TruckPainter old) =>
      old.t != t || old.unit != unit || old.color != color;
}

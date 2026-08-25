import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Gráfico de área ligero (sin librerías) para la serie de ingresos del
/// dashboard: relleno degradado esmeralda + línea + punto final marcado.
class MiniAreaChart extends StatelessWidget {
  final List<double> values;
  final double height;

  const MiniAreaChart({super.key, required this.values, this.height = 160});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _AreaPainter(values)),
      );
}

class _AreaPainter extends CustomPainter {
  final List<double> values;
  _AreaPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const pad = 8.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final denom = maxV <= 0 ? 1.0 : maxV;

    final pts = <Offset>[];
    if (values.length == 1) {
      final y = pad + h - (values[0] / denom) * h;
      pts.add(Offset(pad, y));
      pts.add(Offset(pad + w, y));
    } else {
      for (var i = 0; i < values.length; i++) {
        final x = pad + w * (i / (values.length - 1));
        final y = pad + h - (values[i] / denom) * h;
        pts.add(Offset(x, y));
      }
    }

    // Línea base (referencia sutil).
    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(pad, pad + h), Offset(pad + w, pad + h), gridPaint);

    // Trazo (línea) suavizado con curvas.
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      final midX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    // Área (cierra hacia la base).
    final areaPath = Path.from(linePath)
      ..lineTo(pts.last.dx, pad + h)
      ..lineTo(pts.first.dx, pad + h)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.28),
          AppColors.primary.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Punto final destacado.
    final last = pts.last;
    canvas.drawCircle(last, 5, Paint()..color = Colors.white);
    canvas.drawCircle(last, 5, Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);
    canvas.drawCircle(last, 2.5, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _AreaPainter old) => old.values != values;
}

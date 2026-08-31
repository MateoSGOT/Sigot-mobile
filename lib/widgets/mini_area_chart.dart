import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Gráfico de área ligero (sin librerías) para la serie de ingresos: relleno
/// degradado esmeralda + línea + punto final, con animación de "crecimiento".
class MiniAreaChart extends StatefulWidget {
  final List<double> values;
  final double height;

  const MiniAreaChart({super.key, required this.values, this.height = 160});

  @override
  State<MiniAreaChart> createState() => _MiniAreaChartState();
}

class _MiniAreaChartState extends State<MiniAreaChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant MiniAreaChart old) {
    super.didUpdateWidget(old);
    if (old.values != widget.values) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _AreaPainter(
              widget.values,
              Curves.easeOutCubic.transform(_c.value),
            ),
          ),
        ),
      );
}

class _AreaPainter extends CustomPainter {
  final List<double> values;
  final double progress;
  _AreaPainter(this.values, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const pad = 8.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final denom = maxV <= 0 ? 1.0 : maxV;
    final base = pad + h;

    Offset ptAt(int i) {
      final x = values.length == 1
          ? (i == 0 ? pad : pad + w)
          : pad + w * (i / (values.length - 1));
      final y = base - (values[i] / denom) * h * progress; // crece desde la base
      return Offset(x, y);
    }

    final pts = <Offset>[];
    if (values.length == 1) {
      pts.add(ptAt(0));
      pts.add(Offset(pad + w, ptAt(0).dy));
    } else {
      for (var i = 0; i < values.length; i++) {
        pts.add(ptAt(i));
      }
    }

    // Línea base sutil.
    canvas.drawLine(
      Offset(pad, base),
      Offset(pad + w, base),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..strokeWidth = 1,
    );

    // Trazo suavizado.
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      final midX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(pts.last.dx, base)
      ..lineTo(pts.first.dx, base)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.28),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Punto final.
    final last = pts.last;
    canvas.drawCircle(last, 5, Paint()..color = Colors.white);
    canvas.drawCircle(
        last,
        5,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    canvas.drawCircle(last, 2.5, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _AreaPainter old) =>
      old.values != values || old.progress != progress;
}

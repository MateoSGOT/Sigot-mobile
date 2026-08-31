import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/sigot_wordmark.dart';
import '../widgets/truck_loader.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _init();
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      auth.checkAuth(),
      Future.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppBrand.brand),
          child: Stack(
            children: [
              // Resplandores ambientales que se desplazan lentamente.
              AnimatedBuilder(
                animation: _drift,
                builder: (context, _) {
                  final d = (_drift.value - 0.5) * 2; // -1..1
                  return Stack(
                    children: [
                      Positioned(
                        bottom: -120 + d * 14,
                        right: -80 - d * 16,
                        child: _glow(360, 0.22),
                      ),
                      Positioned(
                        top: -100 - d * 12,
                        left: -90 + d * 14,
                        child: _glow(300, 0.10),
                      ),
                    ],
                  );
                },
              ),
              // Contenido central con entrada suave (fade + scale) + shimmer.
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, child) => Opacity(
                    opacity: v.clamp(0, 1),
                    child: Transform.scale(scale: 0.92 + 0.08 * v, child: child),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _ShimmerWordmark(fontSize: 42, letterSpacing: 9),
                      const SizedBox(height: 16),
                      Text(
                        'Sistema de Gestión de Órdenes y Taller',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.66),
                          fontSize: 13.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Camión + indicador inferior (aparece un poco después).
              Positioned(
                bottom: 54,
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOut,
                  builder: (context, v, child) =>
                      Opacity(opacity: v.clamp(0, 1), child: child),
                  child: Column(
                    children: [
                      const TruckLoader(size: 32),
                      const SizedBox(height: 12),
                      Text(
                        'Iniciando...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _glow(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppBrand.green.withValues(alpha: opacity),
              AppBrand.green.withValues(alpha: 0),
            ],
          ),
        ),
      );
}

/// Wordmark con un destello (shimmer) que barre las letras periódicamente,
/// sobre el degradado de marca.
class _ShimmerWordmark extends StatefulWidget {
  final double fontSize;
  final double letterSpacing;
  const _ShimmerWordmark({required this.fontSize, required this.letterSpacing});

  @override
  State<_ShimmerWordmark> createState() => _ShimmerWordmarkState();
}

class _ShimmerWordmarkState extends State<_ShimmerWordmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: widget.letterSpacing,
      height: 1.0,
      color: Colors.white,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        SigotWordmark(
            fontSize: widget.fontSize, letterSpacing: widget.letterSpacing),
        AnimatedBuilder(
          animation: _c,
          builder: (context, _) => ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              // Barrido de luz sobre las letras usando stops móviles (sin
              // Matrix4/GradientTransform, para máxima compatibilidad).
              final center = _c.value * 1.6 - 0.3;
              const half = 0.18;
              final a = (center - half).clamp(0.0, 0.996).toDouble();
              final b = center.clamp(a + 0.002, 0.998).toDouble();
              final d = (center + half).clamp(b + 0.002, 1.0).toDouble();
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: [a, b, d],
              ).createShader(bounds);
            },
            child: Text('SIGOT', style: style),
          ),
        ),
      ],
    );
  }
}

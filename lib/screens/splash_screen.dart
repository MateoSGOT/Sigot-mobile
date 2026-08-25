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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
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
          // Mismo degradado del sidebar de la web (navy → teal → esmeralda).
          decoration: const BoxDecoration(gradient: AppBrand.brand),
          child: Stack(
            children: [
              // Brillo esmeralda ambiental (como el panel del login web).
              Positioned(
                bottom: -120,
                right: -80,
                child: _glow(360, 0.22),
              ),
              Positioned(
                top: -100,
                left: -90,
                child: _glow(300, 0.10),
              ),
              // Contenido central con entrada suave (fade + scale).
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, child) => Opacity(
                    opacity: t.clamp(0, 1),
                    child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SigotWordmark(fontSize: 40, letterSpacing: 9),
                      const SizedBox(height: 14),
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
              // Indicador inferior — anillo verde de marca.
              Positioned(
                bottom: 56,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const TruckLoader(size: 26),
                    const SizedBox(height: 14),
                    Text(
                      'Iniciando...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.42),
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
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

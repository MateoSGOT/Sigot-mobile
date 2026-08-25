import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Wordmark "SIGOT" en paridad con la web (`.sidebar__logo-text`):
/// relleno con degradado blanco → menta → verde, peso 800, tracking amplio y
/// un halo verde sutil. Reutilizable en splash, login y header.
class SigotWordmark extends StatelessWidget {
  final double fontSize;
  final double? letterSpacing;
  final bool glow;

  const SigotWordmark({
    super.key,
    this.fontSize = 22,
    this.letterSpacing,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    // La web usa 0.22em; en Flutter el tracking es en px → lo escalamos al tamaño.
    final tracking = letterSpacing ?? fontSize * 0.2;
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: tracking,
      height: 1.0,
    );

    final mark = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppBrand.wordmark.createShader(bounds),
      child: Text('SIGOT', style: baseStyle.copyWith(color: Colors.white)),
    );

    if (!glow) return mark;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Capa de halo verde (solo la sombra difusa; el glifo es transparente).
        Text(
          'SIGOT',
          style: baseStyle.copyWith(
            color: Colors.transparent,
            shadows: [
              Shadow(
                color: AppBrand.green.withValues(alpha: 0.45),
                blurRadius: fontSize * 0.7,
              ),
            ],
          ),
        ),
        mark,
      ],
    );
  }
}

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF16a34a); // base: bordes, iconos, texto sobre claro
  // -strong para superficies sólidas con texto blanco <24px (AA-normal >=4.5:1)
  static const Color primaryStrong = Color(0xFF15803d); // 5.02:1 con blanco
  static const Color primaryStrongHover = Color(0xFF166534); // 7.13:1
  static const Color infoStrong = Color(0xFF2563eb); // 5.17:1 con blanco
  static const Color dangerStrong = Color(0xFFdc2626); // 4.83:1 con blanco
  static const Color successStrong = Color(0xFF15803d);
  static const Color accent = Color(0xFFb5f23d);
  static const Color background = Color(0xFFf0f2f5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF111827);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6b7280);
  static const Color error = Color(0xFFef4444);

  static const Color badgePendiente = Color(0xFFf59e0b);
  static const Color badgeEnProceso = Color(0xFF3b82f6);
  static const Color badgeRealizado = Color(0xFF16a34a);
  static const Color badgeInactivo = Color(0xFF6b7280);

  // Foreground OBLIGATORIO por color (regla dura: nunca un color sin su par de texto).
  // Paridad con la web: esmeralda→blanco, lima→oscuro, ámbar→oscuro, resto→blanco.
  static const Color primaryOn = Color(0xFFFFFFFF); // sobre esmeralda
  static const Color accentOn = Color(0xFF111827); // sobre lima (alta luminosidad → texto oscuro)
  static const Color onBadgePendiente = Color(0xFF111827); // ámbar → texto oscuro
  static const Color onBadgeEnProceso = Color(0xFFFFFFFF);
  static const Color onBadgeRealizado = Color(0xFFFFFFFF);
  static const Color onBadgeInactivo = Color(0xFFFFFFFF);

  static const double cardRadius = 12.0;
  static const double inputRadius = 8.0;
  static const double cardElevation = 2.0;
  static const double paddingStd = 16.0;
  static const double buttonHeight = 48.0;
}

/// Escala de espaciado — base 4px (paridad con la web). Único set permitido.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Radios consolidados (paridad con la web). card = md 10.
class AppRadius {
  static const double sm = 6; // inputs, chips
  static const double md = 10; // cards, botones, modales
  static const double lg = 14; // superficies grandes
  static const double full = 9999; // avatares, badges de estado (pill)
}

/// Escala tipográfica con jerarquía real (size / weight) — paridad con la web.
class AppType {
  static const TextStyle display = TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.25);
  static const TextStyle h1 = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25);
  static const TextStyle h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle small = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4);
}

/// Sombras — 3 niveles con propósito (reposo / hover / modal).
class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x29000000), blurRadius: 40, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}

/// Duraciones y curva de animación — paridad con la web.
class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Cubic ease = Cubic(0.4, 0, 0.2, 1);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111827),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.cardRadius),
          ),
          color: AppColors.surface,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppColors.inputRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppColors.inputRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // -strong: fondo sólido con texto blanco de 16px requiere AA-normal 4.5:1
            backgroundColor: AppColors.primaryStrong,
            foregroundColor: Colors.white,
            minimumSize:
                const Size(double.infinity, AppColors.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppColors.inputRadius),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFFb5f23d),
          unselectedItemColor: Color(0xFF6b7280),
          backgroundColor: Color(0xFF111827),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        chipTheme: ChipThemeData(
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          labelStyle: const TextStyle(fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: CircleBorder(),
        ),
      );
}

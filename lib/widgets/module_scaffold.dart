import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import 'sigot_wordmark.dart';

/// Andamiaje compartido de cada módulo: AppBar con degradado de marca
/// (wordmark + logout) y un encabezado de sección (título + subtítulo).
/// El submenú vive en el shell (HomeScreen), así que aquí NO va bottom nav.
class ModuleScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;
  final Widget? floatingActionButton;

  const ModuleScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.floatingActionButton,
  });

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Salir')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final root = Navigator.of(context, rootNavigator: true);
      await context.read<AuthProvider>().logout();
      root.pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleSpacing: 20,
          flexibleSpace: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppBrand.sidebar,
              border: Border(bottom: BorderSide(color: Color(0x1A4ADE80))),
            ),
          ),
          title: const SigotWordmark(fontSize: 20, letterSpacing: 3.5),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _logout(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10)),
                    ),
                    child: const Icon(Icons.logout,
                        color: Colors.white70, size: 19),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _pageHeader(),
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );

  Widget _pageHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 2),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppBrand.green, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

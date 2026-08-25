import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';
import '../widgets/module_scaffold.dart';
import 'dashboard/dashboard_screen.dart';
import 'agenda/agenda_screen.dart';
import 'compras/compras_screen.dart';
import 'ordenes/ordenes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  // Un Navigator por pestaña → el submenú del shell queda FIJO aunque se entre
  // a los detalles de cualquier módulo (se apilan dentro de su pestaña).
  final List<GlobalKey<NavigatorState>> _navKeys =
      List.generate(4, (_) => GlobalKey<NavigatorState>());

  final _navItems = const [
    _NavItem(Icons.dashboard_rounded, 'Dashboard'),
    _NavItem(Icons.calendar_today, 'Agenda'),
    _NavItem(Icons.shopping_cart, 'Compras'),
    _NavItem(Icons.assignment, 'Órdenes'),
  ];

  Widget _rootFor(int i) => switch (i) {
        0 => const ModuleScaffold(
            title: 'Dashboard',
            subtitle: 'Reportes del taller',
            body: DashboardScreen(),
          ),
        1 => const ModuleScaffold(
            title: 'Agenda',
            subtitle: 'Tus citas programadas',
            body: AgendaScreen(),
          ),
        2 => const ModuleScaffold(
            title: 'Compras',
            subtitle: 'Compras registradas',
            body: ComprasScreen(),
          ),
        _ => const ModuleScaffold(
            title: 'Órdenes',
            subtitle: 'Órdenes de trabajo',
            body: OrdenesScreen(),
          ),
      };

  void _onTap(int i) {
    if (i == _idx) {
      // Volver a tocar la pestaña activa → regresa a la raíz del módulo.
      _navKeys[i].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _idx = i);
    }
  }

  void _handleBack(bool didPop, Object? result) {
    if (didPop) return;
    final nav = _navKeys[_idx].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    } else if (_idx != 0) {
      setState(() => _idx = 0); // vuelve al Dashboard
    } else {
      SystemNavigator.pop(); // sale de la app
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: _handleBack,
        child: Scaffold(
          body: IndexedStack(
            index: _idx,
            children: [
              for (var i = 0; i < _navItems.length; i++)
                _TabNavigator(navigatorKey: _navKeys[i], child: _rootFor(i)),
            ],
          ),
          bottomNavigationBar: _SigotBottomNav(
            index: _idx,
            items: _navItems,
            onTap: _onTap,
          ),
        ),
      );
}

/// Navigator propio de cada pestaña (mantiene su pila de detalles).
class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _TabNavigator({required this.navigatorKey, required this.child});

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => child,
        ),
      );
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

/// Submenú inferior FIJO: fondo navy y píldora verde animada en el ítem activo
/// (icono + etiqueta). Inactivos compactos (solo icono).
class _SigotBottomNav extends StatelessWidget {
  final int index;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _SigotBottomNav({
    required this.index,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppBrand.navyDeep,
          border: Border(top: BorderSide(color: Color(0x1A4ADE80))),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < items.length; i++)
                  _NavButton(
                    item: items[i],
                    active: i == index,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(i);
                    },
                  ),
              ],
            ),
          ),
        ),
      );
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.ease,
          padding: EdgeInsets.symmetric(
            horizontal: active ? 15 : 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppBrand.green.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active
                  ? AppBrand.green.withValues(alpha: 0.22)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: active ? 1.08 : 1.0,
                duration: AppMotion.base,
                curve: AppMotion.ease,
                child: Icon(
                  item.icon,
                  size: 22,
                  color: active
                      ? AppBrand.green
                      : Colors.white.withValues(alpha: 0.55),
                ),
              ),
              AnimatedSize(
                duration: AppMotion.base,
                curve: AppMotion.ease,
                child: active
                    ? Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            color: AppBrand.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
}

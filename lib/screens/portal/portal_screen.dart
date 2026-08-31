import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/portal_models.dart';
import '../../models/vehiculo_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/portal_provider.dart';
import '../../services/api_service.dart';
import '../../utils/format.dart';
import '../../widgets/sigot_wordmark.dart';
import '../../widgets/detail_ui.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../login_screen.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {
  int _idx = 0;

  static const _titles = ['Mi cuenta', 'Mis vehículos', 'Mis órdenes', 'Mis citas'];
  static const _subtitles = [
    'Tu información personal',
    'Tus vehículos registrados',
    'Tus órdenes de trabajo',
    'Tus citas agendadas',
  ];
  static const _navItems = [
    (Icons.person, 'Cuenta'),
    (Icons.directions_car, 'Vehículos'),
    (Icons.assignment, 'Órdenes'),
    (Icons.event, 'Citas'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortalProvider>().load();
    });
  }

  Future<void> _confirmLogout() async {
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
    if (ok == true && mounted) {
      final nav = Navigator.of(context, rootNavigator: true);
      await context.read<AuthProvider>().logout();
      nav.pushReplacement(
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
          flexibleSpace: const SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppBrand.sidebar,
                border: Border(bottom: BorderSide(color: Color(0x1A4ADE80))),
              ),
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
                  onTap: _confirmLogout,
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
            Expanded(
              child: IndexedStack(
                index: _idx,
                children: [
                  _tabCuenta(),
                  _tabVehiculos(),
                  _tabOrdenes(),
                  _tabCitas(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _bottomNav(),
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
                  Text(_titles[_idx],
                      style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.1)),
                  Text(_subtitles[_idx],
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      );

  // ─────────────────────────── Cuenta ───────────────────────────
  Widget _tabCuenta() {
    final c = context.watch<AuthProvider>().cliente;
    if (c == null) {
      return const EmptyStateWidget(
        icon: Icons.person_off_outlined,
        message: 'No hay datos del cliente',
      );
    }
    final inicial = c.nombre.isNotEmpty ? c.nombre[0].toUpperCase() : '?';
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppBrand.green, AppColors.primary],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(inicial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.nombre,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    if ((c.documento ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          '${c.tipoDocumento ?? 'Doc'} · ${c.documento}',
                          style: const TextStyle(
                              fontSize: 13.5, color: AppColors.textMuted),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DetailGroup(
          title: 'Datos de contacto',
          children: [
            DetailTile(
                icon: Icons.email_outlined,
                label: 'Correo',
                value: (c.correo ?? '').isEmpty ? '—' : c.correo!),
            DetailTile(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                value: (c.telefono ?? '').isEmpty ? '—' : c.telefono!),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────── Vehículos ───────────────────────────
  Widget _tabVehiculos() => _listBody<VehiculoModel>(
        items: context.watch<PortalProvider>().vehiculos,
        emptyIcon: Icons.directions_car_outlined,
        emptyMsg: 'No tienes vehículos registrados',
        builder: (v, i) => AnimatedEntrance(
          index: i,
          child: _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_car,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(v.placa,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${v.marca} ${v.modelo} ${v.anio}'.trim(),
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary)),
                if (v.color != null && v.color!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _row(Icons.color_lens, v.color!),
                ],
              ],
            ),
          ),
        ),
      );

  // ─────────────────────────── Órdenes ───────────────────────────
  Widget _tabOrdenes() => _listBody<PortalOrden>(
        items: context.watch<PortalProvider>().ordenes,
        emptyIcon: Icons.assignment_outlined,
        emptyMsg: 'No tienes órdenes registradas',
        builder: (o, i) => AnimatedEntrance(
          index: i,
          child: _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Orden #${o.idOrden}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary)),
                    ),
                    _badge(o.estadoLabel, _ordenColor(o.estado)),
                  ],
                ),
                const SizedBox(height: 8),
                _row(Icons.directions_car, o.vehiculo),
                const SizedBox(height: 4),
                _row(Icons.calendar_today, formatDate(o.fechaIngreso)),
                if ((o.diagnostico ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(o.diagnostico!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
        ),
      );

  // ─────────────────────────── Citas ───────────────────────────
  Widget _tabCitas() => _listBody<PortalCita>(
        items: context.watch<PortalProvider>().citas,
        emptyIcon: Icons.event_busy_outlined,
        emptyMsg: 'No tienes citas registradas',
        builder: (c, i) => AnimatedEntrance(
          index: i,
          child: _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${formatDate(c.fecha)}  ·  ${c.hora}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary),
                      ),
                    ),
                    _badge(c.estadoCita, _citaColor(c.estadoCita)),
                  ],
                ),
                const Divider(height: 16),
                _row(Icons.directions_car, c.vehiculoPlaca),
                const SizedBox(height: 4),
                _row(Icons.engineering, c.empleadoNombre),
                if ((c.descripcion ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _row(Icons.description, c.descripcion!),
                ],
              ],
            ),
          ),
        ),
      );

  // ─────────────────────────── Helpers ───────────────────────────
  Widget _listBody<T>({
    required List<T> items,
    required IconData emptyIcon,
    required String emptyMsg,
    required Widget Function(T item, int index) builder,
  }) {
    final prov = context.watch<PortalProvider>();
    if (prov.state == LoadState.loading) return const LoadingWidget();
    if (prov.state == LoadState.error) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        message: prov.error ?? 'Error al cargar',
        onRetry: prov.load,
        retryLabel: 'Reintentar',
      );
    }
    if (items.isEmpty) {
      return EmptyStateWidget(icon: emptyIcon, message: emptyMsg);
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: prov.load,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: items.length,
        itemBuilder: (_, i) => builder(items[i], i),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppColors.paddingStd),
        child: child,
      );

  Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      );

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );

  Color _ordenColor(int estado) => switch (estado) {
        1 => AppColors.badgePendiente,
        2 => AppColors.badgeEnProceso,
        3 => AppColors.badgeRealizado,
        _ => AppColors.badgeInactivo,
      };

  Color _citaColor(String estado) => switch (estado) {
        'Confirmada' => AppColors.badgeEnProceso,
        'Atendida' => AppColors.badgeRealizado,
        'Cancelada' => AppColors.error,
        'NoAsistio' => AppColors.badgeInactivo,
        _ => AppColors.badgePendiente,
      };

  Widget _bottomNav() => Container(
        decoration: const BoxDecoration(
          color: AppBrand.navyDeep,
          border: Border(top: BorderSide(color: Color(0x1A4ADE80))),
          boxShadow: [
            BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < _navItems.length; i++)
                  _navButton(i),
              ],
            ),
          ),
        ),
      );

  Widget _navButton(int i) {
    final active = i == _idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _idx = i);
      },
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.ease,
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 12, vertical: 10),
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
            Icon(_navItems[i].$1,
                size: 22,
                color: active
                    ? AppBrand.green
                    : Colors.white.withValues(alpha: 0.55)),
            AnimatedSize(
              duration: AppMotion.base,
              curve: AppMotion.ease,
              child: active
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(_navItems[i].$2,
                          style: const TextStyle(
                              color: AppBrand.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

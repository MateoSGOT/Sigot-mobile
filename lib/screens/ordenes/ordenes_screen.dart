import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/orden_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/orden_card.dart';
import '../../widgets/detail_ui.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'orden_detail_screen.dart';

class OrdenesScreen extends StatefulWidget {
  const OrdenesScreen({super.key});

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  static const _filters = [
    null,
    'Pendiente',
    'En proceso',
    'Realizado',
  ];
  static const _labels = ['Todos', 'Pendiente', 'En proceso', 'Realizado'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdenProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdenProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por vehículo, cliente...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
            ),
            onChanged: provider.setSearch,
          ),
        ),
        const SizedBox(height: 10),
        SigotFilterChips(
          labels: _labels,
          selected: _filters.indexOf(provider.filterEstado),
          onSelected: (i) => provider.setFilter(_filters[i]),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildBody(provider)),
      ],
    );
  }

  Widget _buildBody(OrdenProvider provider) {
    switch (provider.state) {
      case LoadState.loading:
        return const LoadingWidget();
      case LoadState.error:
        return EmptyStateWidget(
          icon: Icons.error_outline,
          message: provider.error ?? 'Error al cargar órdenes',
          onRetry: provider.load,
          retryLabel: 'Reintentar',
        );
      case LoadState.loaded:
      case LoadState.idle:
        final items = provider.filtered;
        if (items.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.assignment_outlined,
            message: 'No hay órdenes registradas',
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: provider.load,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, i) => AnimatedEntrance(
              index: i,
              child: OrdenCard(
                orden: items[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OrdenDetailScreen(idOrden: items[i].idOrden),
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}

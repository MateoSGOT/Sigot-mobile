import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/vehiculo_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/vehiculo_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'vehiculo_detail_screen.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({super.key});

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculoProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehiculoProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppColors.paddingStd),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por placa, marca, cliente...',
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
        Expanded(child: _buildBody(provider)),
      ],
    );
  }

  Widget _buildBody(VehiculoProvider provider) {
    switch (provider.state) {
      case LoadState.loading:
        return const LoadingWidget();
      case LoadState.error:
        return EmptyStateWidget(
          icon: Icons.error_outline,
          message: provider.error ?? 'Error al cargar vehículos',
          onRetry: provider.load,
          retryLabel: 'Reintentar',
        );
      case LoadState.loaded:
      case LoadState.idle:
        final items = provider.filtered;
        if (items.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.directions_car_outlined,
            message: 'No hay vehículos registrados',
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: provider.load,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, i) => VehiculoCard(
              vehiculo: items[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      VehiculoDetailScreen(vehiculo: items[i]),
                ),
              ),
            ),
          ),
        );
    }
  }
}

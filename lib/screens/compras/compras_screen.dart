import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/compra_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/compra_card.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'compra_detail_screen.dart';

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompraProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompraProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por proveedor, repuesto...',
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: provider.setSearch,
          ),
        ),
        const SizedBox(height: 10),
        SigotFilterChips(
          labels: const ['Todas', 'Vigentes', 'Anuladas'],
          selected: provider.filter.index,
          onSelected: (i) => provider.setFilter(CompraFilter.values[i]),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildBody(provider)),
      ],
    );
  }

  Widget _buildBody(CompraProvider provider) {
    switch (provider.state) {
      case LoadState.loading:
        return const LoadingWidget();
      case LoadState.error:
        return EmptyStateWidget(
          icon: Icons.error_outline,
          message: provider.error ?? 'Error al cargar compras',
          onRetry: provider.load,
          retryLabel: 'Reintentar',
        );
      case LoadState.loaded:
      case LoadState.idle:
        final items = provider.filtered;
        if (items.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.shopping_cart_outlined,
            message: 'No hay compras registradas',
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: provider.load,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: items.length,
            itemBuilder: (ctx, i) => CompraCard(
              compra: items[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CompraDetailScreen(compra: items[i]),
                ),
              ),
            ),
          ),
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/agenda_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/agenda_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'agenda_detail_screen.dart';
import 'agenda_form_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendaProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgendaProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppColors.paddingStd),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar por cliente, vehículo...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: provider.setSearch,
          ),
        ),
        Expanded(child: _buildBody(provider)),
      ],
    );
  }

  Widget _buildBody(AgendaProvider provider) {
    switch (provider.state) {
      case LoadState.loading:
        return const LoadingWidget();
      case LoadState.error:
        return EmptyStateWidget(
          icon: Icons.error_outline,
          message: provider.error ?? 'Error al cargar agenda',
          onRetry: provider.load,
          retryLabel: 'Reintentar',
        );
      case LoadState.loaded:
      case LoadState.idle:
        final items = provider.filtered;
        if (items.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.calendar_today_outlined,
            message: 'No hay citas registradas',
          );
        }
        return Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: provider.load,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, i) => AgendaCard(
                  agenda: items[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AgendaDetailScreen(agenda: items[i]),
                    ),
                  ),
                  onVerOrden: items[i].ordenId != null
                      ? () => _goToOrden(items[i].ordenId!)
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AgendaFormScreen()),
                ).then((_) => provider.load()),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
    }
  }

  void _goToOrden(int ordenId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ver orden #$ordenId')),
    );
  }
}

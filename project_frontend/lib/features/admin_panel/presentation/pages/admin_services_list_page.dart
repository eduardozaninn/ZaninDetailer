import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../di/injection_container.dart' as di;
import '../providers/admin_service_provider.dart';
import '../widgets/admin_list_scaffold.dart';
import '../widgets/confirm_delete_dialog.dart';

class AdminServicesListPage extends StatelessWidget {
  const AdminServicesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminServiceProvider>()..fetchServices(),
      child: const _AdminServicesListView(),
    );
  }
}

class _AdminServicesListView extends StatelessWidget {
  const _AdminServicesListView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminServiceProvider>();

    return AdminListScaffold(
      title: 'Catálogo de Serviços',
      isLoading: provider.isLoading,
      isEmpty: provider.services.isEmpty,
      onRefresh: provider.fetchServices,
      itemCount: provider.services.length,
      itemBuilder: (context, index) {
        final service = provider.services[index];
        return Card(
          color: AppTheme.cardBackground,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8)),
              child: service.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          Image.network(service.imageUrl!, fit: BoxFit.cover))
                  : const Icon(Icons.car_repair, color: Colors.white54),
            ),
            title: Text(service.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${StringUtils.formatCurrency(service.price)} • ${service.durationDisplay}',
                style: const TextStyle(color: AppTheme.primaryRed)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white54),
                  onPressed: () async {
                    await context.push(AppRouter.adminEditService,
                        extra: service);
                    if (context.mounted) {
                      context.read<AdminServiceProvider>().fetchServices();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white54),
                  onPressed: () async {
                    final confirmar = await confirmDeleteDialog(context,
                        title: 'Excluir Serviço?');
                    if (confirmar && context.mounted) {
                      await context
                          .read<AdminServiceProvider>()
                          .deleteService(service.id);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: () async {
          await context.push(AppRouter.adminNewService);
          if (context.mounted) {
            context.read<AdminServiceProvider>().fetchServices();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

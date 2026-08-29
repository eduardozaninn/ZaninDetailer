import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../di/injection_container.dart' as di;
import '../providers/admin_brand_provider.dart';
import '../widgets/admin_list_scaffold.dart';
import '../widgets/confirm_delete_dialog.dart';

class AdminBrandsListPage extends StatelessWidget {
  const AdminBrandsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminBrandProvider>()..fetchBrands(),
      child: const _AdminBrandsListView(),
    );
  }
}

class _AdminBrandsListView extends StatelessWidget {
  const _AdminBrandsListView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBrandProvider>();

    return AdminListScaffold(
      title: 'Marcas de Veículos',
      isLoading: provider.isLoading,
      isEmpty: provider.brands.isEmpty,
      onRefresh: provider.fetchBrands,
      itemCount: provider.brands.length,
      itemBuilder: (context, index) {
        final brand = provider.brands[index];
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
              child: brand.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(brand.imageUrl!, fit: BoxFit.cover))
                  : const Icon(Icons.branding_watermark,
                      color: Colors.white54),
            ),
            title: Text(brand.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white54),
                  onPressed: () async {
                    await context.push(AppRouter.adminEditBrand, extra: brand);
                    if (context.mounted) {
                      context.read<AdminBrandProvider>().fetchBrands();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white54),
                  onPressed: () async {
                    final confirmar =
                        await confirmDeleteDialog(context, title: 'Excluir Marca?');
                    if (confirmar && context.mounted) {
                      await context.read<AdminBrandProvider>().deleteBrand(brand.id);
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
          await context.push(AppRouter.adminNewBrand);
          if (context.mounted) {
            context.read<AdminBrandProvider>().fetchBrands();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

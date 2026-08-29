import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection_container.dart' as di;
import '../../data/models/showcase_model.dart';
import '../providers/admin_showcase_provider.dart';

class AdminShowcasesPage extends StatelessWidget {
  const AdminShowcasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminShowcaseProvider>()..fetchShowcases(),
      child: const _AdminShowcasesView(),
    );
  }
}

class _AdminShowcasesView extends StatelessWidget {
  const _AdminShowcasesView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminShowcaseProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vitrine de Trabalhos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryRed),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fotos exibidas na seção "Últimos Trabalhos"',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                _SlotBadge(count: provider.showcases.length),
              ],
            ),
          ),
          if (provider.isLoading && provider.showcases.isEmpty)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed),
              ),
            )
          else if (provider.showcases.isEmpty)
            Expanded(child: _EmptyState(onAdd: () => _addPhoto(context, provider)))
          else
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primaryRed,
                onRefresh: provider.fetchShowcases,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: provider.showcases.length,
                  itemBuilder: (context, index) {
                    return _ShowcaseCard(
                      showcase: provider.showcases[index],
                      onReplace: () =>
                          _replacePhoto(context, provider.showcases[index], provider),
                      onDelete: () =>
                          _confirmDelete(context, provider.showcases[index], provider),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: provider.canAddMore
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryRed,
              icon: const Icon(Icons.add_photo_alternate_outlined,
                  color: Colors.white),
              label: const Text('Adicionar foto',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed:
                  provider.isLoading ? null : () => _addPhoto(context, provider),
            )
          : null,
    );
  }

  Future<void> _addPhoto(
      BuildContext context, AdminShowcaseProvider provider) async {
    final success = await provider.addShowcase();
    if (!context.mounted) return;
    _showResult(context, provider, success, 'Foto adicionada com sucesso!');
  }

  Future<void> _replacePhoto(BuildContext context, ShowcaseModel showcase,
      AdminShowcaseProvider provider) async {
    final success = await provider.replaceShowcase(showcase.id);
    if (!context.mounted) return;
    _showResult(context, provider, success, 'Foto substituída com sucesso!');
  }

  Future<void> _confirmDelete(BuildContext context, ShowcaseModel showcase,
      AdminShowcaseProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover foto?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'A imagem será removida da vitrine e do servidor.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white38),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    final success = await provider.deleteShowcase(showcase.id);
    if (!context.mounted) return;
    _showResult(context, provider, success, 'Foto removida com sucesso.');
  }

  void _showResult(BuildContext context, AdminShowcaseProvider provider,
      bool success, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success
          ? successMessage
          : (provider.errorMessage ?? 'Não foi possível concluir.')),
      backgroundColor: success ? AppTheme.successGreen : AppTheme.primaryRed,
    ));
  }
}

class _SlotBadge extends StatelessWidget {
  const _SlotBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final isFull = count >= 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isFull
            ? Colors.white.withValues(alpha: 0.05)
            : AppTheme.primaryRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFull
              ? Colors.white.withValues(alpha: 0.1)
              : AppTheme.primaryRed.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        '$count / 5 fotos',
        style: TextStyle(
          color: isFull ? Colors.grey[500] : AppTheme.primaryRed,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined,
              size: 72, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 20),
          const Text('Nenhuma foto adicionada ainda.',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Adicione até 5 fotos dos seus trabalhos.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: onAdd,
            icon: const Icon(Icons.add_photo_alternate_outlined,
                color: Colors.white),
            label: const Text('Adicionar primeira foto',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.showcase,
    required this.onReplace,
    required this.onDelete,
  });

  final ShowcaseModel showcase;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            showcase.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryRed, strokeWidth: 2)),
                  ),
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1A1A1A),
              child: const Icon(Icons.broken_image_outlined,
                  color: Colors.white24, size: 40),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _OverlayButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Substituir',
                  onTap: onReplace,
                ),
                _OverlayButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Remover',
                  color: Colors.redAccent,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
    this.tooltip = '',
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

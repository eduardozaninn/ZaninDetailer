import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Layout compartilhado pelas telas de listagem admin (marcas, serviços,
/// usuários): AppBar, spinner no primeiro carregamento, "puxar para
/// atualizar" e lista rolável.
class AdminListScaffold extends StatelessWidget {
  final String title;
  final bool isLoading;
  final bool isEmpty;
  final Future<void> Function() onRefresh;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;

  const AdminListScaffold({
    super.key,
    required this.title,
    required this.isLoading,
    required this.isEmpty,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    this.floatingActionButton,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 100),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.primaryRed),
      ),
      body: isLoading && isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed))
          : RefreshIndicator(
              color: AppTheme.primaryRed,
              onRefresh: onRefresh,
              child: ListView.builder(
                padding: padding,
                itemCount: itemCount,
                itemBuilder: itemBuilder,
              ),
            ),
      floatingActionButton: floatingActionButton,
    );
  }
}

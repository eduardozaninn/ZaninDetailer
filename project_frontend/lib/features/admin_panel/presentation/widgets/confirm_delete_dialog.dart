import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Diálogo de confirmação de exclusão compartilhado pelas telas de
/// listagem admin (marcas, serviços, usuários). Retorna `true` se o
/// usuário confirmou.
Future<bool> confirmDeleteDialog(
  BuildContext context, {
  required String title,
  String confirmLabel = 'Excluir',
}) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.dialogBackground,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white38),
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.dangerRed,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child:
              Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
  return confirmar == true;
}

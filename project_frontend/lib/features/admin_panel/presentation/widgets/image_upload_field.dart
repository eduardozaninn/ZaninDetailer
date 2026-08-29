import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import 'dashed_rect_painter.dart';

/// Campo de upload de imagem reutilizado nos formulários de marca/serviço.
///
/// Modo "criar" (sem [existingImageUrl]): passe [onRemove] para permitir
/// desfazer a seleção (ícone de fechar sobre a prévia).
/// Modo "editar" (com [existingImageUrl]): omita [onRemove] — tocar na
/// prévia dispara [onPick] de novo, trocando a imagem (ícone de lápis).
class ImageUploadField extends StatelessWidget {
  final XFile? selectedImage;
  final String? existingImageUrl;
  final String uploadLabel;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const ImageUploadField({
    super.key,
    required this.selectedImage,
    required this.uploadLabel,
    required this.onPick,
    this.existingImageUrl,
    this.onRemove,
  });

  bool get _hasImage => selectedImage != null || existingImageUrl != null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _hasImage ? _buildImagePreview() : _buildDashedUploadArea(textTheme);
  }

  Widget _buildDashedUploadArea(TextTheme textTheme) {
    return GestureDetector(
      onTap: onPick,
      child: CustomPaint(
        painter: DashedRectPainter(
            color: Colors.white.withValues(alpha: 0.2), strokeWidth: 2, gap: 6),
        child: Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(24),
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined,
                  color: Colors.white.withValues(alpha: 0.4), size: 60),
              const SizedBox(height: 16),
              Text(uploadLabel,
                  textAlign: TextAlign.center, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final bool showRemove = onRemove != null;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.primaryRed.withValues(alpha: 0.5), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: selectedImage == null
                ? Image.network(existingImageUrl!, fit: BoxFit.cover)
                : (kIsWeb
                    ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                    : Image.file(File(selectedImage!.path), fit: BoxFit.cover)),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: showRemove ? onRemove : onPick,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle),
              child: Icon(showRemove ? Icons.close : Icons.edit,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../di/injection_container.dart' as di;
import '../../data/models/admin_brand_model.dart';
import '../providers/admin_brand_provider.dart';
import '../widgets/admin_custom_input.dart';
import '../widgets/admin_form_scaffold.dart';
import '../widgets/image_upload_field.dart';

class AdminEditBrandPage extends StatelessWidget {
  final AdminBrandModel brand;
  const AdminEditBrandPage({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminBrandProvider>(),
      child: _AdminEditBrandView(brand: brand),
    );
  }
}

class _AdminEditBrandView extends StatefulWidget {
  final AdminBrandModel brand;
  const _AdminEditBrandView({required this.brand});

  @override
  State<_AdminEditBrandView> createState() => _AdminEditBrandViewState();
}

class _AdminEditBrandViewState extends State<_AdminEditBrandView> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _nomeController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.brand.name);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) setState(() => _image = pickedFile);
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('O nome é obrigatório!'),
          backgroundColor: Colors.redAccent));
      return;
    }

    final provider = context.read<AdminBrandProvider>();
    final sucesso = await provider.updateBrand(
      id: widget.brand.id,
      name: _nomeController.text.trim(),
      image: _image,
    );

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Marca atualizada!'), backgroundColor: Colors.green));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(provider.errorMessage ?? 'Erro ao atualizar'),
            backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AdminBrandProvider>().isLoading;

    return AdminFormScaffold(
      title: 'Editar Marca',
      isLoading: isLoading,
      saveLabel: 'Salvar Alterações',
      onSave: _handleSave,
      children: [
        AdminCustomInput(hint: 'Nome da Marca', controller: _nomeController),
        const SizedBox(height: 32),
        ImageUploadField(
          selectedImage: _image,
          existingImageUrl: widget.brand.imageUrl,
          uploadLabel: 'Atualizar logo da marca',
          onPick: _pickImage,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

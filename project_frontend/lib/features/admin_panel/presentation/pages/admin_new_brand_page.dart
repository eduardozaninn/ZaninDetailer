import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../di/injection_container.dart' as di;
import '../providers/admin_brand_provider.dart';
import '../widgets/admin_custom_input.dart';
import '../widgets/admin_form_scaffold.dart';
import '../widgets/image_upload_field.dart';

class AdminNewBrandPage extends StatelessWidget {
  const AdminNewBrandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminBrandProvider>(),
      child: const _AdminNewBrandView(),
    );
  }
}

class _AdminNewBrandView extends StatefulWidget {
  const _AdminNewBrandView();

  @override
  State<_AdminNewBrandView> createState() => _AdminNewBrandViewState();
}

class _AdminNewBrandViewState extends State<_AdminNewBrandView> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nomeController = TextEditingController();

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

  void _removeImage() => setState(() => _image = null);

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('O nome da marca é obrigatório!'),
          backgroundColor: Colors.redAccent));
      return;
    }

    final provider = context.read<AdminBrandProvider>();
    final sucesso = await provider.createBrand(
      name: _nomeController.text.trim(),
      image: _image,
    );

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Marca criada com sucesso!'),
            backgroundColor: Colors.green));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(provider.errorMessage ?? 'Erro ao salvar marca'),
            backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AdminBrandProvider>().isLoading;

    return AdminFormScaffold(
      title: 'Nova Marca',
      isLoading: isLoading,
      saveLabel: 'Salvar Marca',
      onSave: _handleSave,
      children: [
        AdminCustomInput(hint: 'Nome da Marca', controller: _nomeController),
        const SizedBox(height: 32),
        ImageUploadField(
          selectedImage: _image,
          uploadLabel: 'Faça upload da logo da marca',
          onPick: _pickImage,
          onRemove: _removeImage,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

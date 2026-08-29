import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../di/injection_container.dart' as di;
import '../providers/admin_service_provider.dart';
import '../widgets/admin_custom_input.dart';
import '../widgets/admin_form_scaffold.dart';
import '../widgets/image_upload_field.dart';

class AdminNewServicePage extends StatelessWidget {
  const AdminNewServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminServiceProvider>(),
      child: const _AdminNewServiceView(),
    );
  }
}

class _AdminNewServiceView extends StatefulWidget {
  const _AdminNewServiceView();

  @override
  State<_AdminNewServiceView> createState() => _AdminNewServiceViewState();
}

class _AdminNewServiceViewState extends State<_AdminNewServiceView> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _tempoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _tempoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) setState(() => _image = pickedFile);
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  void _removeImage() => setState(() => _image = null);

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    if (_nomeController.text.trim().isEmpty ||
        _precoController.text.trim().isEmpty ||
        _tempoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Preencha todos os campos!'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    final provider = context.read<AdminServiceProvider>();

    final sucesso = await provider.createService(
      name: _nomeController.text.trim(),
      price: _precoController.text.trim().replaceAll(',', '.'),
      durationMinutes: _tempoController.text.trim(),
      description: _descricaoController.text.trim(),
      image: _image,
    );

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Serviço criado com sucesso!'),
              backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.errorMessage ?? 'Erro ao salvar serviço'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AdminServiceProvider>().isLoading;

    return AdminFormScaffold(
      title: 'Novo Serviço',
      isLoading: isLoading,
      saveLabel: 'Salvar Serviço',
      onSave: _handleSave,
      children: [
        AdminCustomInput(hint: 'Nome do Serviço', controller: _nomeController),
        const SizedBox(height: 16),
        AdminCustomInput(
          hint: 'Descrição do Serviço (Opcional)',
          controller: _descricaoController,
        ),
        const SizedBox(height: 16),
        AdminCustomInput(
            hint: 'Preço (ex: 150.00)',
            prefixText: 'R\$ ',
            controller: _precoController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true)),
        const SizedBox(height: 16),
        AdminCustomInput(
            hint: 'Duração em minutos (ex: 120)',
            controller: _tempoController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 32),
        ImageUploadField(
          selectedImage: _image,
          uploadLabel: 'Faça upload da imagem de destaque do serviço',
          onPick: _pickImage,
          onRemove: _removeImage,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

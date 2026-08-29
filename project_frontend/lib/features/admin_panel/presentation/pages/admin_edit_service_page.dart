import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../di/injection_container.dart' as di;
import '../../data/models/admin_service_model.dart';
import '../providers/admin_service_provider.dart';
import '../widgets/admin_custom_input.dart';
import '../widgets/admin_form_scaffold.dart';
import '../widgets/image_upload_field.dart';

class AdminEditServicePage extends StatelessWidget {
  final AdminServiceModel service;
  const AdminEditServicePage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminServiceProvider>(),
      child: _AdminEditServiceView(service: service),
    );
  }
}

class _AdminEditServiceView extends StatefulWidget {
  final AdminServiceModel service;
  const _AdminEditServiceView({required this.service});

  @override
  State<_AdminEditServiceView> createState() => _AdminEditServiceViewState();
}

class _AdminEditServiceViewState extends State<_AdminEditServiceView> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nomeController;
  late TextEditingController _precoController;
  late TextEditingController _tempoController;
  late TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.service.name);
    _precoController =
        TextEditingController(text: widget.service.price.toStringAsFixed(2));
    _tempoController = TextEditingController(
        text: widget.service.durationMinutes.toString());
    _descricaoController =
        TextEditingController(text: widget.service.description ?? '');
  }

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
          source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) setState(() => _image = pickedFile);
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    if (_nomeController.text.trim().isEmpty ||
        _precoController.text.trim().isEmpty ||
        _tempoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Preencha os campos obrigatórios!'),
          backgroundColor: Colors.redAccent));
      return;
    }

    final provider = context.read<AdminServiceProvider>();
    final sucesso = await provider.updateService(
      id: widget.service.id,
      name: _nomeController.text.trim(),
      price: _precoController.text.trim().replaceAll(',', '.'),
      durationMinutes: _tempoController.text.trim(),
      description: _descricaoController.text.trim(),
      image: _image,
    );

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Serviço atualizado!'),
            backgroundColor: Colors.green));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(provider.errorMessage ?? 'Erro'),
            backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AdminServiceProvider>().isLoading;

    return AdminFormScaffold(
      title: 'Editar Serviço',
      isLoading: isLoading,
      saveLabel: 'Salvar Alterações',
      onSave: _handleSave,
      children: [
        AdminCustomInput(hint: 'Nome do Serviço', controller: _nomeController),
        const SizedBox(height: 16),
        AdminCustomInput(
            hint: 'Preço (ex: 150.00)',
            prefixText: 'R\$ ',
            controller: _precoController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true)),
        const SizedBox(height: 16),
        AdminCustomInput(
            hint: 'Duração em minutos',
            controller: _tempoController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        AdminCustomInput(
            hint: 'Descrição do Serviço', controller: _descricaoController),
        const SizedBox(height: 32),
        ImageUploadField(
          selectedImage: _image,
          existingImageUrl: widget.service.imageUrl,
          uploadLabel: 'Atualizar imagem de destaque',
          onPick: _pickImage,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

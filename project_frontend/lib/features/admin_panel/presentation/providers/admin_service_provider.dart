import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/admin_service_model.dart';
import '../../domain/repositories/i_admin_repository.dart';

class AdminServiceProvider extends ChangeNotifier {
  final IAdminRepository _repository;

  AdminServiceProvider({required IAdminRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AdminServiceModel> _services = [];
  List<AdminServiceModel> get services => _services;

  Future<void> fetchServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getServices();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (list) => _services = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteService(int id) async {
    final result = await _repository.deleteService(id);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        _services.removeWhere((s) => s.id == id);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> createService({
    required String name,
    required String price,
    required String durationMinutes,
    String? description,
    XFile? image,
  }) async {
    if (name.isEmpty || price.isEmpty || durationMinutes.isEmpty) {
      _errorMessage = 'Preencha todos os campos obrigatórios.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final double parsedPrice = double.tryParse(price) ?? 0.0;
    final int parsedDuration = int.tryParse(durationMinutes) ?? 0;

    final newService = AdminServiceModel(
      name: name,
      price: parsedPrice,
      durationMinutes: parsedDuration,
      description: description,
    );

    final result = await _repository.createService(newService, image);

    _isLoading = false;

    return result.fold(
      (failure) {
        debugPrint("Erro na camada de dados: ${failure.message}");
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        debugPrint("Serviço salvo com sucesso!");
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateService({
    required int id,
    required String name,
    required String price,
    required String durationMinutes,
    String? description,
    XFile? image,
  }) async {
    if (name.isEmpty || price.isEmpty || durationMinutes.isEmpty) {
      _errorMessage = 'Preencha todos os campos obrigatórios.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final double parsedPrice = double.tryParse(price) ?? 0.0;
    final int parsedDuration = int.tryParse(durationMinutes) ?? 0;

    final updatedService = AdminServiceModel(
      id: id,
      name: name,
      price: parsedPrice,
      durationMinutes: parsedDuration,
      description: description,
    );

    final result =
        await _repository.updateService(id, updatedService, image);

    _isLoading = false;

    return result.fold(
      (failure) {
        debugPrint("Erro ao atualizar: ${failure.message}");
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        debugPrint("Serviço atualizado com sucesso!");
        notifyListeners();
        return true;
      },
    );
  }
}

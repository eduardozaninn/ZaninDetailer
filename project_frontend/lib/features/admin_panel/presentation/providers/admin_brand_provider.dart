import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/admin_brand_model.dart';
import '../../domain/repositories/i_admin_repository.dart';

class AdminBrandProvider extends ChangeNotifier {
  final IAdminRepository _repository;

  AdminBrandProvider({required IAdminRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AdminBrandModel> _brands = [];
  List<AdminBrandModel> get brands => _brands;

  Future<void> fetchBrands() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getBrands();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (list) => _brands = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBrand({required String name, XFile? image}) async {
    if (name.isEmpty) {
      _errorMessage = 'O nome da marca é obrigatório.';
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result =
        await _repository.createBrand(AdminBrandModel(name: name), image);
    _isLoading = false;
    return result.fold(
      (f) {
        _errorMessage = f.message;
        notifyListeners();
        return false;
      },
      (s) {
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateBrand(
      {required int id, required String name, XFile? image}) async {
    if (name.isEmpty) {
      _errorMessage = 'O nome da marca é obrigatório.';
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.updateBrand(
        id, AdminBrandModel(id: id, name: name), image);
    _isLoading = false;
    return result.fold(
      (f) {
        _errorMessage = f.message;
        notifyListeners();
        return false;
      },
      (s) {
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteBrand(int id) async {
    final result = await _repository.deleteBrand(id);
    return result.fold(
      (f) {
        _errorMessage = f.message;
        notifyListeners();
        return false;
      },
      (s) {
        _brands.removeWhere((m) => m.id == id);
        notifyListeners();
        return true;
      },
    );
  }
}

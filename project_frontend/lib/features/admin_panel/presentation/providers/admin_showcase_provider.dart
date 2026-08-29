import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/showcase_model.dart';
import '../../domain/repositories/i_admin_repository.dart';

class AdminShowcaseProvider extends ChangeNotifier {
  final IAdminRepository _repository;
  final _picker = ImagePicker();

  AdminShowcaseProvider({required IAdminRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ShowcaseModel> _showcases = [];
  List<ShowcaseModel> get showcases => _showcases;
  bool get canAddMore => _showcases.length < 5;

  Future<void> fetchShowcases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getShowcases();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (list) => _showcases = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addShowcase() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.createShowcase(image);
    final success = result.fold((f) {
      _errorMessage = f.message;
      return false;
    }, (_) => true);

    if (success) await fetchShowcases();
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> replaceShowcase(int id) async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.updateShowcase(id, image);
    final success = result.fold((f) {
      _errorMessage = f.message;
      return false;
    }, (_) => true);

    if (success) await fetchShowcases();
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteShowcase(int id) async {
    final result = await _repository.deleteShowcase(id);
    return result.fold(
      (f) {
        _errorMessage = f.message;
        notifyListeners();
        return false;
      },
      (_) {
        _showcases.removeWhere((v) => v.id == id);
        notifyListeners();
        return true;
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/models/admin_appointment_model.dart';
import '../../data/models/admin_service_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/i_admin_repository.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/string_utils.dart';

class AdminProvider extends ChangeNotifier {
  final IAdminRepository _repository;

  AdminProvider({required IAdminRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  List<AdminAppointmentModel> _todayAppointments = [];
  List<AdminAppointmentModel> get todayAppointments => _todayAppointments;

  List<AdminServiceModel> _services = [];

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await fetchAppointments();
  }

  List<AdminAppointmentModel> get activeAppointments => _todayAppointments
      .where((a) => !a.status.toLowerCase().contains('cancel'))
      .toList();

  String get totalAppointments =>
      activeAppointments.length.toString().padLeft(2, '0');

  String get projectedRevenue {
    double total = 0.0;
    for (var appointment in activeAppointments) {
      total += appointment.totalPrice ?? 0.0;
    }

    return StringUtils.formatCurrency(total);
  }

  String serviceName(int serviceId) {
    for (final service in _services) {
      if (service.id == serviceId) return service.name;
    }
    return 'Serviço #$serviceId';
  }

  Future<void> fetchMyProfile() async {
    final result = await _repository.getMyProfile();
    result.fold(
      (failure) => debugPrint("Erro ao carregar perfil: ${failure.message}"),
      (user) {
        _currentUser = user;
        notifyListeners();
      },
    );
  }

  String? _appointmentsErrorMessage;
  String? get appointmentsErrorMessage => _appointmentsErrorMessage;

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _appointmentsErrorMessage = null;
    notifyListeners();

    await fetchMyProfile();

    if (_services.isEmpty) {
      final servicesResult = await _repository.getServices();
      servicesResult.fold((_) {}, (services) => _services = services);
    }

    final result = await _repository.getTodayAppointments(_selectedDate);

    result.fold(
      (failure) {
        debugPrint("Erro: ${failure.message}");
        _todayAppointments = [];
        _appointmentsErrorMessage = failure.message;
      },
      (appointments) => _todayAppointments = appointments,
    );

    _isLoading = false;
    notifyListeners();
  }

  String? _appointmentActionErrorMessage;
  String? get appointmentActionErrorMessage => _appointmentActionErrorMessage;

  Future<bool> rescheduleAppointment(
      int appointmentId, DateTime newScheduledStart) async {
    _appointmentActionErrorMessage = null;

    final isoDateStr = DateTimeUtils.toIsoWithBrazilOffset(newScheduledStart);

    final result =
        await _repository.rescheduleAppointment(appointmentId, isoDateStr);

    return result.fold((failure) {
      debugPrint("Erro ao reagendar agendamento: ${failure.message}");
      _appointmentActionErrorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) async {
      await fetchAppointments();
      return true;
    });
  }

  Future<bool> cancelAppointment(int appointmentId, String reason) async {
    _appointmentActionErrorMessage = null;

    final result = await _repository.cancelAppointment(appointmentId, reason);

    return result.fold((failure) {
      debugPrint("Erro ao cancelar agendamento: ${failure.message}");
      _appointmentActionErrorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) async {
      await fetchAppointments();
      return true;
    });
  }

  Future<bool> completeAppointment(int appointmentId) async {
    _appointmentActionErrorMessage = null;

    final result = await _repository.completeAppointment(appointmentId);

    return result.fold((failure) {
      debugPrint("Erro ao concluir agendamento: ${failure.message}");
      _appointmentActionErrorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) async {
      await fetchAppointments();
      return true;
    });
  }

  Future<bool> updateClientData({
    required int appointmentId,
    required String fullName,
    required String phone,
    required String licensePlate,
    required String vehicleBrandModel,
  }) async {
    _appointmentActionErrorMessage = null;

    final result = await _repository.updateClientData(
      appointmentId: appointmentId,
      fullName: fullName,
      phone: phone,
      licensePlate: licensePlate,
      vehicleBrandModel: vehicleBrandModel,
    );

    return result.fold((failure) {
      debugPrint("Erro ao atualizar dados do cliente: ${failure.message}");
      _appointmentActionErrorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) async {
      await fetchAppointments();
      return true;
    });
  }
}

import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/i_booking_repository.dart';
import '../../data/models/service_model.dart';
import '../../data/models/appointment_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure_mapper.dart';

class BookingRepositoryImpl implements IBookingRepository {
  final ApiClient _apiClient;

  BookingRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Either<Failure, List<ServiceModel>>> getServices() async {
    try {
      final response = await _apiClient.dio.get('/services/');
      final dynamic responseData = response.data;

      final List<dynamic> servicesJson =
          responseData is List ? responseData : (responseData['items'] ?? []);

      final services = servicesJson
          .map<ServiceModel>(
              (json) => ServiceModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(services);
    } catch (e) {
      return Left(FailureMapper.map(e, fallback: 'Erro ao buscar serviços.'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLastWorks() async {
    try {
      final response = await _apiClient.dio.get('/showcases/');
      final List<dynamic> items = response.data['items'] ?? [];
      final urls = items
          .map<String>(
              (j) => (j as Map<String, dynamic>)['image_url'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
      return Right(urls);
    } catch (e) {
      return Left(
          FailureMapper.map(e, fallback: 'Erro ao buscar últimos trabalhos.'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableSlots(
      int serviceId, String date) async {
    try {
      final response = await _apiClient.dio
          .get('/appointments/available-slots', queryParameters: {
        'service_id': serviceId,
        'date': date,
      });

      final List<dynamic> slotsJson = response.data['slots'] ?? [];

      final RegExp timePattern = RegExp(r'T(\d{2}:\d{2})');
      final List<String> availableTimes = slotsJson
          .map<String>((slot) {
            final String start = slot['start'] as String? ?? '';
            return timePattern.firstMatch(start)?.group(1) ?? '';
          })
          .where((time) => time.isNotEmpty)
          .toList();

      return Right(availableTimes);
    } catch (e) {
      return Left(FailureMapper.map(e,
          fallback: 'Erro ao buscar horários disponíveis.'));
    }
  }

  @override
  Future<Either<Failure, AppointmentModel>> submitBooking({
    required int serviceId,
    required String scheduledStartIso,
    required String clientName,
    required String whatsapp,
    required String licensePlate,
    required String vehicleModel,
  }) async {
    try {
      final requestData = {
        "service_id": serviceId,
        "scheduled_start": scheduledStartIso,
        "client": {
          "full_name": clientName,
          "phone": whatsapp,
          "license_plate": licensePlate,
          "vehicle_brand_model": vehicleModel
        }
      };

      final response =
          await _apiClient.dio.post('/appointments/', data: requestData);

      final appointment =
          AppointmentModel.fromJson(response.data as Map<String, dynamic>);
      return Right(appointment);
    } catch (e) {
      return Left(
          FailureMapper.map(e, fallback: 'Erro ao confirmar o agendamento.'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBrands() async {
    try {
      final response = await _apiClient.dio.get('/brands/');
      final dynamic responseData = response.data;

      final List<dynamic> brandsJson =
          responseData is List ? responseData : (responseData['items'] ?? []);

      final brands = brandsJson
          .map<String>((json) {
            final brandMap = json as Map<String, dynamic>;
            return brandMap['image_url'] as String? ?? '';
          })
          .where((url) => url.isNotEmpty)
          .toList();

      return Right(brands);
    } catch (e) {
      return Left(
          FailureMapper.map(e, fallback: 'Erro ao buscar marcas parceiras.'));
    }
  }

}

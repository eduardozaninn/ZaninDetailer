import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_admin_repository.dart';
import '../models/admin_service_model.dart';
import '../models/admin_brand_model.dart';
import '../models/admin_appointment_model.dart';
import '../models/user_model.dart';
import '../models/showcase_model.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final ApiClient _apiClient;

  AdminRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<void> _addImageIfPresent(FormData formData, XFile? imagem) async {
    if (imagem == null) return;
    formData.files.add(MapEntry(
      'image',
      await MultipartFile.fromFile(imagem.path, filename: imagem.name),
    ));
  }

  @override
  Future<Either<Failure, UserModel>> getMyProfile() async {
    try {
      final response = await _apiClient.dio.get('/admin/users/me');
      return Right(UserModel.fromJson(response.data));
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> createService(
      AdminServiceModel service, XFile? image) async {
    try {
      final formData = FormData.fromMap({
        'name': service.name,
        'price': service.price,
        'duration_minutes': service.durationMinutes,
        'description': service.description ?? '',
      });

      await _addImageIfPresent(formData, image);

      await _apiClient.dio.post('/services/', data: formData);

      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateService(
      int id, AdminServiceModel service, XFile? image) async {
    try {
      final formData = FormData.fromMap({
        'name': service.name,
        'price': service.price,
        'duration_minutes': service.durationMinutes,
        'description': service.description ?? '',
      });

      await _addImageIfPresent(formData, image);

      await _apiClient.dio.patch('/services/$id', data: formData);
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminAppointmentModel>>> getTodayAppointments(
      DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await _apiClient.dio.get(
        '/appointments/',
        queryParameters: {'date': formattedDate},
      );

      final responseData = response.data;
      if (responseData is! List) {
        return Left(ServerFailure(
            'Formato de resposta inesperado ao buscar agendamentos.'));
      }

      final appointments = responseData
          .map((json) => AdminAppointmentModel.fromJson(json))
          .toList();

      return Right(appointments);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminServiceModel>>> getServices() async {
    try {
      final response = await _apiClient.dio.get('/services/');

      final List<dynamic> items = response.data['items'] ?? [];
      final services =
          items.map((json) => AdminServiceModel.fromJson(json)).toList();
      return Right(services);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteService(int id) async {
    try {
      await _apiClient.dio.delete('/services/$id');
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminBrandModel>>> getBrands() async {
    try {
      final response = await _apiClient.dio.get('/brands/');
      final List<dynamic> items = response.data['items'] ?? [];
      return Right(
          items.map((json) => AdminBrandModel.fromJson(json)).toList());
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> createBrand(
      AdminBrandModel brand, XFile? image) async {
    try {
      final formData = FormData.fromMap({'name': brand.name});
      await _addImageIfPresent(formData, image);
      await _apiClient.dio.post('/brands/', data: formData);
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBrand(
      int id, AdminBrandModel brand, XFile? image) async {
    try {
      final formData = FormData.fromMap({'name': brand.name});
      await _addImageIfPresent(formData, image);
      await _apiClient.dio.patch('/brands/$id', data: formData);
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBrand(int id) async {
    try {
      await _apiClient.dio.delete('/brands/$id');
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, List<ShowcaseModel>>> getShowcases() async {
    try {
      final response = await _apiClient.dio.get('/showcases/');
      final List<dynamic> items = response.data['items'] ?? [];
      return Right(items.map((j) => ShowcaseModel.fromJson(j)).toList());
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> createShowcase(XFile image) async {
    try {
      final formData = FormData();
      await _addImageIfPresent(formData, image);
      await _apiClient.dio.post('/showcases/', data: formData);
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateShowcase(int id, XFile image) async {
    try {
      final formData = FormData();
      await _addImageIfPresent(formData, image);
      await _apiClient.dio.patch('/showcases/$id', data: formData);
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteShowcase(int id) async {
    try {
      await _apiClient.dio.delete('/showcases/$id');
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> rescheduleAppointment(
      int appointmentId, String newScheduledStartIso) async {
    try {
      await _apiClient.dio.patch(
        '/appointments/$appointmentId/reschedule',
        data: {'scheduled_start': newScheduledStartIso},
      );
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelAppointment(
      int appointmentId, String reason) async {
    try {
      await _apiClient.dio.post(
        '/appointments/$appointmentId/cancel',
        data: {'reason': reason},
      );
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> completeAppointment(int appointmentId) async {
    try {
      await _apiClient.dio.post('/appointments/$appointmentId/complete');
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateClientData({
    required int appointmentId,
    required String fullName,
    required String phone,
    required String licensePlate,
    required String vehicleBrandModel,
  }) async {
    try {
      await _apiClient.dio.patch(
        '/appointments/$appointmentId/client',
        data: {
          'full_name': fullName,
          'phone': phone,
          'license_plate': licensePlate,
          'vehicle_brand_model': vehicleBrandModel,
        },
      );
      return const Right(true);
    } catch (e) {
      return Left(FailureMapper.map(e));
    }
  }
}

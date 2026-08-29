import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/admin_service_model.dart';
import '../../data/models/admin_appointment_model.dart';
import '../../data/models/admin_brand_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/showcase_model.dart';

abstract class IAdminRepository {
  Future<Either<Failure, UserModel>> getMyProfile();
  Future<Either<Failure, List<AdminAppointmentModel>>> getTodayAppointments(
      DateTime date);

  Future<Either<Failure, List<AdminServiceModel>>> getServices();
  Future<Either<Failure, bool>> createService(
      AdminServiceModel service, XFile? image);
  Future<Either<Failure, bool>> deleteService(int id);
  Future<Either<Failure, bool>> updateService(
      int id, AdminServiceModel service, XFile? image);

  Future<Either<Failure, List<AdminBrandModel>>> getBrands();
  Future<Either<Failure, bool>> createBrand(
      AdminBrandModel brand, XFile? image);
  Future<Either<Failure, bool>> updateBrand(
      int id, AdminBrandModel brand, XFile? image);
  Future<Either<Failure, bool>> deleteBrand(int id);

  Future<Either<Failure, bool>> rescheduleAppointment(
      int appointmentId, String newScheduledStartIso);
  Future<Either<Failure, bool>> cancelAppointment(
      int appointmentId, String reason);
  Future<Either<Failure, bool>> completeAppointment(int appointmentId);
  Future<Either<Failure, bool>> updateClientData({
    required int appointmentId,
    required String fullName,
    required String phone,
    required String licensePlate,
    required String vehicleBrandModel,
  });

  Future<Either<Failure, List<ShowcaseModel>>> getShowcases();
  Future<Either<Failure, bool>> createShowcase(XFile image);
  Future<Either<Failure, bool>> updateShowcase(int id, XFile image);
  Future<Either<Failure, bool>> deleteShowcase(int id);
}

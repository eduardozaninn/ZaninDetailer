import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/user_model.dart';

abstract class IUserManagementRepository {
  Future<Either<Failure, List<UserModel>>> getUsers();

  Future<Either<Failure, UserModel>> createUser(
      String email, String password, String fullName);

  Future<Either<Failure, UserModel>> updateUser(String id,
      {String? fullName, String? password});

  Future<Either<Failure, bool>> deleteUser(String id);
}

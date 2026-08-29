import 'package:dio/dio.dart';
import '../error/failures.dart';
import 'dio_error_extractor.dart';

class FailureMapper {
  static Failure map(
    dynamic error, {
    String fallback = 'Erro inesperado ao conectar com o servidor.',
  }) {
    if (error is DioException && isNetworkError(error)) {
      return NetworkFailure();
    }
    return ServerFailure(
        DioErrorExtractor.extractMessage(error, fallback: fallback));
  }

  static bool isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }
}

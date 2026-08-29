import 'package:dio/dio.dart';

class DioErrorExtractor {
  static String extractMessage(
    dynamic error, {
    String fallback = 'Erro inesperado ao conectar com o servidor.',
  }) {
    if (error is DioException && error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          return detail[0]['msg']?.toString() ?? 'Erro de validação.';
        }
      }
    }
    return fallback;
  }
}

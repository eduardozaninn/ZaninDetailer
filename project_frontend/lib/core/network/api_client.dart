import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  // Garante que, se várias requisições levarem 401 ao mesmo tempo, só uma
  // dispara o refresh de verdade — as demais esperam o mesmo resultado.
  Completer<bool>? _refreshCompleter;

  static const String baseUrl = 'https://zanindetailer-production.up.railway.app/api/v1/';

  ApiClient({required FlutterSecureStorage storage}) : _storage = storage {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
      contentType: 'application/json',
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: StoreKeys.accessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          final isUnauthorized = e.response?.statusCode == 401;
          final isLoginRequest = e.requestOptions.path.contains('/auth/login');

          if (isUnauthorized && !isLoginRequest) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final newAccessToken =
                  await _storage.read(key: StoreKeys.accessToken);
              e.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              try {
                final retryResponse = await dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              } catch (_) {
                return handler.next(e);
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await _storage.read(key: StoreKeys.refreshToken);
      if (refreshToken == null) {
        completer.complete(false);
        return false;
      }

      final refreshResponse = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = refreshResponse.data['access_token'];
      final newRefreshToken = refreshResponse.data['refresh_token'];

      await _storage.write(key: StoreKeys.accessToken, value: newAccessToken);
      await _storage.write(
          key: StoreKeys.refreshToken, value: newRefreshToken);

      completer.complete(true);
      return true;
    } catch (_) {
      await _storage.delete(key: StoreKeys.accessToken);
      await _storage.delete(key: StoreKeys.refreshToken);
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}

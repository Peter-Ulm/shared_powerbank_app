import 'package:dio/dio.dart';
import '../env/app_environment.dart';
import '../storage/token_store.dart';
import 'auth_interceptor.dart';

Dio buildDio(AppEnvironment env, TokenStore tokenStore) {
  final dio = Dio(BaseOptions(
    baseUrl: '${env.apiBaseUrl}/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));
  dio.interceptors.add(AuthInterceptor(tokenStore));
  return dio;
}

import 'package:dio/dio.dart';
import '../error/app_exception.dart';
import '../storage/token_store.dart';

/// Attaches the bearer token and converts errors to AppException.
/// (Token refresh-on-401 is added in a later plan when auth endpoints exist.)
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStore);
  final TokenStore _tokenStore;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final tokens = await _tokenStore.read();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: _toAppException(err),
        response: err.response,
        type: err.type,
      ),
    );
  }

  AppException _toAppException(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return const AppException(code: AppException.networkCode);
    }
    final data = err.response?.data;
    if (data is Map && data['error'] is Map) {
      final e = data['error'] as Map;
      return AppException(
        code: (e['code'] as String?) ?? AppException.unknownCode,
        serverMessage: e['message'] as String?,
        details: (e['details'] as Map?)?.cast<String, dynamic>(),
      );
    }
    return const AppException(code: AppException.unknownCode);
  }
}

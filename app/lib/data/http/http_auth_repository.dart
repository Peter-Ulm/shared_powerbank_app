import 'package:dio/dio.dart';
import '../../domain/models/auth.dart';
import '../../domain/repositories/auth_repository.dart';

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._dio);
  final Dio _dio;

  @override
  Future<void> requestOtp(String phone) async {
    await _dio.post('/auth/otp/request', data: {'phone': phone});
  }

  @override
  Future<({AuthTokens tokens, AppUser user})> verifyOtp(String phone, String code) async {
    final res = await _dio.post('/auth/otp/verify', data: {'phone': phone, 'code': code});
    final data = res.data as Map<String, dynamic>;
    return (
      tokens: AuthTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      ),
      user: AppUser.fromJson((data['user'] as Map).cast<String, dynamic>()),
    );
  }

  @override
  Future<AppUser> me() async {
    final res = await _dio.get('/me');
    return AppUser.fromJson((res.data as Map).cast<String, dynamic>());
  }
}

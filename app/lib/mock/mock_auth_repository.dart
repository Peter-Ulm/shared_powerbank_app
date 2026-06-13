import '../domain/models/auth.dart';
import '../domain/repositories/auth_repository.dart';

/// Mock auth: any 6-digit code verifies. Records the last OTP request.
class MockAuthRepository implements AuthRepository {
  String? lastOtpPhone;

  @override
  Future<void> requestOtp(String phone) async {
    lastOtpPhone = phone;
  }

  @override
  Future<({AuthTokens tokens, AppUser user})> verifyOtp(String phone, String code) async {
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      throw const AuthException('OTP_INVALID');
    }
    final user = AppUser(id: 'U-$phone', phone: phone, locale: 'sw', status: 'active');
    const tokens = AuthTokens(accessToken: 'mock-access', refreshToken: 'mock-refresh');
    return (tokens: tokens, user: user);
  }

  @override
  Future<AppUser> me() async =>
      const AppUser(id: 'U-restored', phone: '+255700000000', locale: 'sw', status: 'active');
}

class AuthException implements Exception {
  const AuthException(this.code);
  final String code;
  @override
  String toString() => 'AuthException($code)';
}

import '../models/auth.dart';

abstract class AuthRepository {
  Future<void> requestOtp(String phone);
  Future<({AuthTokens tokens, AppUser user})> verifyOtp(String phone, String code);
  Future<AppUser> me();
}

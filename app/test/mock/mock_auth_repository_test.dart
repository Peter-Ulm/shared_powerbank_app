import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/mock/mock_auth_repository.dart';

void main() {
  test('requestOtp records the phone', () async {
    final repo = MockAuthRepository();
    await repo.requestOtp('+255712345678');
    expect(repo.lastOtpPhone, '+255712345678');
  });
  test('verifyOtp returns tokens + user for a 6-digit code', () async {
    final repo = MockAuthRepository();
    final res = await repo.verifyOtp('+255712345678', '123456');
    expect(res.tokens.accessToken, isNotEmpty);
    expect(res.user.phone, '+255712345678');
  });
  test('verifyOtp rejects a non-6-digit code', () async {
    final repo = MockAuthRepository();
    expect(() => repo.verifyOtp('+255712345678', '12'), throwsA(isA<AuthException>()));
  });
}

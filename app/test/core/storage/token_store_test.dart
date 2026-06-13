import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/domain/models/auth.dart';

void main() {
  test('write then read returns the same tokens', () async {
    final store = InMemoryTokenStore();
    await store.write(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    final read = await store.read();
    expect(read?.accessToken, 'a');
    expect(read?.refreshToken, 'r');
  });

  test('clear removes tokens', () async {
    final store = InMemoryTokenStore();
    await store.write(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    await store.clear();
    expect(await store.read(), isNull);
  });
}

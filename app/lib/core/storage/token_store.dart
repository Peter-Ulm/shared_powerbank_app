import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/auth.dart';

abstract class TokenStore {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._storage);
  final FlutterSecureStorage _storage;
  static const _access = 'access_token';
  static const _refresh = 'refresh_token';

  @override
  Future<AuthTokens?> read() async {
    final a = await _storage.read(key: _access);
    final r = await _storage.read(key: _refresh);
    if (a == null || r == null) return null;
    return AuthTokens(accessToken: a, refreshToken: r);
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    await _storage.write(key: _access, value: tokens.accessToken);
    await _storage.write(key: _refresh, value: tokens.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }
}

class InMemoryTokenStore implements TokenStore {
  AuthTokens? _tokens;
  @override
  Future<AuthTokens?> read() async => _tokens;
  @override
  Future<void> write(AuthTokens tokens) async => _tokens = tokens;
  @override
  Future<void> clear() async => _tokens = null;
}

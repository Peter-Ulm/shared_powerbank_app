import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:marijoy_app/core/env/app_environment.dart';
import 'package:marijoy_app/core/error/app_exception.dart';
import 'package:marijoy_app/core/network/dio_client.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/domain/models/auth.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late InMemoryTokenStore store;

  setUp(() {
    store = InMemoryTokenStore();
    dio = buildDio(
      const AppEnvironment(flavor: AppFlavor.dev, apiBaseUrl: 'https://x'),
      store,
    );
    adapter = DioAdapter(dio: dio);
  });

  test('attaches bearer token when present', () async {
    await store.write(const AuthTokens(accessToken: 'tok123', refreshToken: 'r'));
    adapter.onGet('/me', (s) => s.reply(200, {'ok': true}));
    final res = await dio.get('/me');
    expect(res.requestOptions.headers['Authorization'], 'Bearer tok123');
  });

  test('maps error envelope to AppException with code', () async {
    adapter.onPost('/orders', (s) => s.reply(409, {
          'error': {'code': 'INSUFFICIENT_BANKS', 'message': 'no banks'}
        }));
    try {
      await dio.post('/orders');
      fail('should have thrown');
    } on DioException catch (e) {
      expect(e.error, isA<AppException>());
      expect((e.error as AppException).code, 'INSUFFICIENT_BANKS');
    }
  });
}

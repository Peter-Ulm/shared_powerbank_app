import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/env/app_environment.dart';

void main() {
  test('mock environment uses mock data source', () {
    const env = AppEnvironment(flavor: AppFlavor.mock, apiBaseUrl: 'http://localhost');
    expect(env.useMockData, isTrue);
  });
  test('dev environment does not use mock data', () {
    const env = AppEnvironment(flavor: AppFlavor.dev, apiBaseUrl: 'https://dev.example');
    expect(env.useMockData, isFalse);
  });
  test('fromDartDefine defaults to mock flavor', () {
    final env = AppEnvironment.fromDartDefine();
    expect(env.flavor, AppFlavor.mock);
  });
}

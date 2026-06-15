import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage/token_store.dart';
import 'storage/app_prefs.dart';
import 'env/app_environment.dart';
import 'location/location_service.dart';
import 'network/dio_client.dart';
import 'notifications/notification_service.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/cabinets_repository.dart';
import '../domain/repositories/orders_repository.dart';
import '../domain/repositories/rentals_repository.dart';
import '../mock/mock_auth_repository.dart';
import '../mock/mock_repositories.dart';
import '../mock/scenario_engine.dart';
import '../data/http/http_auth_repository.dart';
import '../data/http/http_cabinets_repository.dart';
import '../data/http/http_orders_repository.dart';
import '../data/http/http_rentals_repository.dart';

final environmentProvider = Provider<AppEnvironment>((_) => AppEnvironment.fromDartDefine());

final appPrefsProvider = Provider<AppPrefs>((ref) {
  throw UnimplementedError('appPrefsProvider must be overridden in main()');
});

final scenarioEngineProvider = Provider<ScenarioEngine>((ref) {
  final engine = ScenarioEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

final tokenStoreProvider = Provider<TokenStore>((ref) {
  // Real secure storage on device; tests override with InMemoryTokenStore.
  return SecureTokenStore(const FlutterSecureStorage());
});

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(environmentProvider);
  return buildDio(env, ref.watch(tokenStoreProvider));
});

final locationServiceProvider = Provider<LocationService>((ref) => const MockLocationService());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => const NoopNotificationService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(environmentProvider).useMockData
      ? MockAuthRepository()
      : HttpAuthRepository(ref.watch(dioProvider));
});

final cabinetsRepositoryProvider = Provider<CabinetsRepository>((ref) {
  return ref.watch(environmentProvider).useMockData
      ? MockCabinetsRepository()
      : HttpCabinetsRepository(ref.watch(dioProvider));
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return ref.watch(environmentProvider).useMockData
      ? MockOrdersRepository(ref.watch(scenarioEngineProvider))
      : HttpOrdersRepository(ref.watch(dioProvider));
});

final rentalsRepositoryProvider = Provider<RentalsRepository>((ref) {
  return ref.watch(environmentProvider).useMockData
      ? MockRentalsRepository(ref.watch(scenarioEngineProvider))
      : HttpRentalsRepository(ref.watch(dioProvider));
});

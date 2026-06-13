import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage/token_store.dart';
import '../domain/repositories/auth_repository.dart';
import '../mock/mock_auth_repository.dart';
import '../domain/repositories/cabinets_repository.dart';
import '../domain/repositories/orders_repository.dart';
import '../domain/repositories/rentals_repository.dart';
import '../mock/mock_repositories.dart';
import '../mock/scenario_engine.dart';
import 'env/app_environment.dart';
import 'storage/app_prefs.dart';

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

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final cabinetsRepositoryProvider = Provider<CabinetsRepository>((ref) {
  return MockCabinetsRepository();
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return MockOrdersRepository(ref.watch(scenarioEngineProvider));
});

final rentalsRepositoryProvider = Provider<RentalsRepository>((ref) {
  return MockRentalsRepository(ref.watch(scenarioEngineProvider));
});

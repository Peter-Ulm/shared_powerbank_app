import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Auth state: true when a token exists. Real wiring lands in a later plan;
/// for now it defaults to false (unauthenticated).
final isAuthenticatedProvider = StateProvider<bool>((_) => false);

final cabinetsRepositoryProvider = Provider<CabinetsRepository>((ref) {
  return MockCabinetsRepository();
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return MockOrdersRepository(ref.watch(scenarioEngineProvider));
});

final rentalsRepositoryProvider = Provider<RentalsRepository>((ref) {
  return MockRentalsRepository(ref.watch(scenarioEngineProvider));
});

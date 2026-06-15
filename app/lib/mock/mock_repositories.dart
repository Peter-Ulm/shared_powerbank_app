import '../domain/models/cabinet.dart';
import '../domain/models/order.dart';
import '../domain/models/rental.dart';
import '../domain/models/wallet.dart';
import '../domain/repositories/cabinets_repository.dart';
import '../domain/repositories/orders_repository.dart';
import '../domain/repositories/rentals_repository.dart';
import 'fixtures.dart';
import 'scenario_engine.dart';

class MockCabinetsRepository implements CabinetsRepository {
  @override
  Future<List<Cabinet>> nearby({required double lat, required double lng, double radiusM = 2000}) async =>
      mockCabinets;
  @override
  Future<Cabinet> byId(String id) async => mockCabinets.firstWhere((c) => c.id == id);
}

class MockOrdersRepository implements OrdersRepository {
  MockOrdersRepository(this._engine);
  final ScenarioEngine _engine;
  var _seq = 0;

  @override
  Future<Order> create({
    required String cabinetId,
    required int qty,
    Wallet? wallet,
    required String idempotencyKey,
  }) async {
    final id = 'ORD${(++_seq).toString().padLeft(3, '0')}';
    return _engine.createOrder(id, qty, qty * kUnitPriceTzs);
  }

  @override
  Future<Order> byId(String id) async => _engine.order(id);
  @override
  Stream<Order> watch(String id) => _engine.watchOrder(id);
  @override
  Future<void> repush(String id) async {}
  @override
  Future<void> cancel(String id) async {}
}

class MockRentalsRepository implements RentalsRepository {
  MockRentalsRepository(this._engine);
  final ScenarioEngine _engine;

  @override
  Future<List<Rental>> list({RentalStatus? status}) async {
    final all = [..._engine.rentals, ...mockHistoryRentals];
    return all.where((r) => status == null || r.status == status).toList();
  }
  @override
  Future<Rental> byId(String id) async => _engine.rentals.firstWhere((r) => r.id == id);
  @override
  Stream<List<Rental>> watchActive() => _engine.watchRentals();
}

import 'dart:async';
import '../domain/models/order.dart';
import '../domain/models/rental.dart';

/// Fault branches the engine can simulate (SPEC §9).
enum MockFault { none, ejectFail, partial, pushTimeout }

/// Drives the mock rental loop on timers. Uses an injectable [now] so tests
/// can run it with fake_async. Tick durations are short for demo/tests.
class ScenarioEngine {
  ScenarioEngine({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  MockFault fault = MockFault.none;

  final _orders = <String, Order>{};
  final _orderControllers = <String, StreamController<Order>>{};
  final _rentals = <Rental>[];
  final _rentalsController = StreamController<List<Rental>>.broadcast();

  static const tick = Duration(seconds: 2);

  Order createOrder(String id, int qty, int amountTzs) {
    final order = Order(
      id: id,
      status: OrderStatus.paymentPending,
      amountTzs: amountTzs,
      fulfilment: [
        for (var i = 1; i <= qty; i++)
          FulfilmentUnit(unit: i, status: FulfilmentStatus.pending),
      ],
    );
    _orders[id] = order;
    _orderControllers[id] = StreamController<Order>.broadcast();
    _schedule(id, qty);
    return order;
  }

  Stream<Order> watchOrder(String id) async* {
    yield _orders[id]!;
    yield* _orderControllers[id]!.stream;
  }

  Order order(String id) => _orders[id]!;
  Stream<List<Rental>> watchRentals() => _rentalsController.stream;
  List<Rental> get rentals => List.unmodifiable(_rentals);

  void _emit(Order o) {
    _orders[o.id] = o;
    _orderControllers[o.id]?.add(o);
  }

  void _schedule(String id, int qty) {
    if (fault == MockFault.pushTimeout) {
      Timer(tick * 2, () => _emit(_orders[id]!.copyWith(status: OrderStatus.failed)));
      return;
    }
    Timer(tick, () {
      _emit(_orders[id]!.copyWith(status: OrderStatus.fulfilling));
      _ejectUnits(id, qty);
    });
  }

  void _ejectUnits(String id, int qty) {
    var delay = tick;
    for (var i = 1; i <= qty; i++) {
      final unit = i;
      final fails = (fault == MockFault.ejectFail) ||
          (fault == MockFault.partial && unit == qty);
      Timer(delay, () => _completeUnit(id, unit, fails));
      delay += tick;
    }
  }

  void _completeUnit(String id, int unit, bool fails) {
    final o = _orders[id]!;
    final updated = o.fulfilment
        .map((u) => u.unit == unit
            ? u.copyWith(
                status: fails ? FulfilmentStatus.failed : FulfilmentStatus.ejected,
                slot: fails ? null : 6 + unit)
            : u)
        .toList();
    final allDone = updated.every((u) =>
        u.status == FulfilmentStatus.ejected || u.status == FulfilmentStatus.failed);
    final anyOk = updated.any((u) => u.status == FulfilmentStatus.ejected);
    final anyFail = updated.any((u) => u.status == FulfilmentStatus.failed);
    var status = o.status;
    if (allDone) {
      status = anyFail && anyOk
          ? OrderStatus.partiallyFulfilled
          : anyOk
              ? OrderStatus.fulfilled
              : OrderStatus.refunded;
    }
    _emit(o.copyWith(fulfilment: updated, status: status));
    if (!fails) _activateRental(id, unit);
  }

  void _activateRental(String orderId, int unit) {
    final started = _now();
    _rentals.add(Rental(
      id: '$orderId-R$unit',
      powerbankId: 'PB-$orderId-$unit',
      status: RentalStatus.active,
      startedAt: started,
      dueAt: started.add(const Duration(hours: 5)),
    ));
    _rentalsController.add(List.of(_rentals));
  }

  void dispose() {
    for (final c in _orderControllers.values) {
      c.close();
    }
    _rentalsController.close();
  }
}

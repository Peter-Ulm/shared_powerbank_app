import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/domain/models/order.dart';
import 'package:marijoy_app/mock/scenario_engine.dart';

void main() {
  test('happy path: single bank goes pending -> fulfilled and a rental activates', () {
    fakeAsync((async) {
      final engine = ScenarioEngine(now: () => DateTime(2026, 6, 13, 10));
      engine.createOrder('ORD1', 1, 1000);
      async.elapse(const Duration(seconds: 10));

      final order = engine.order('ORD1');
      expect(order.status, OrderStatus.fulfilled);
      expect(order.fulfilment.single.status, FulfilmentStatus.ejected);
      expect(engine.rentals.length, 1);
      expect(engine.rentals.single.dueAt.difference(engine.rentals.single.startedAt).inHours, 5);
      engine.dispose();
    });
  });

  test('partial fault: 2 of 2 -> one ejected, one failed, status partiallyFulfilled', () {
    fakeAsync((async) {
      final engine = ScenarioEngine(now: () => DateTime(2026, 6, 13, 10))
        ..fault = MockFault.partial;
      engine.createOrder('ORD2', 2, 2000);
      async.elapse(const Duration(seconds: 12));

      final order = engine.order('ORD2');
      expect(order.status, OrderStatus.partiallyFulfilled);
      expect(engine.rentals.length, 1);
      engine.dispose();
    });
  });

  test('pushTimeout fault: order ends failed, no rentals', () {
    fakeAsync((async) {
      final engine = ScenarioEngine(now: () => DateTime(2026, 6, 13, 10))
        ..fault = MockFault.pushTimeout;
      engine.createOrder('ORD3', 1, 1000);
      async.elapse(const Duration(seconds: 10));

      expect(engine.order('ORD3').status, OrderStatus.failed);
      expect(engine.rentals, isEmpty);
      engine.dispose();
    });
  });
}

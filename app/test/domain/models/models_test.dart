import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/domain/models/order.dart';
import 'package:marijoy_app/domain/models/rental.dart';

void main() {
  test('Order parses snake_case status from API json', () {
    final order = Order.fromJson({
      'id': '01ORD',
      'status': 'partially_fulfilled',
      'amountTzs': 2000,
      'fulfilment': [
        {'unit': 1, 'status': 'ejected', 'slot': 7},
        {'unit': 2, 'status': 'failed'},
      ],
    });
    expect(order.status, OrderStatus.partiallyFulfilled);
    expect(order.fulfilment.first.slot, 7);
    expect(order.fulfilment[1].status, FulfilmentStatus.failed);
  });

  test('Rental parses ISO timestamps and defaults overage to 0', () {
    final rental = Rental.fromJson({
      'id': '01RNT',
      'powerbankId': 'PB1',
      'status': 'active',
      'startedAt': '2026-06-13T10:00:00Z',
      'dueAt': '2026-06-13T15:00:00Z',
    });
    expect(rental.status, RentalStatus.active);
    expect(rental.overageTzs, 0);
    expect(rental.dueAt.difference(rental.startedAt).inHours, 5);
  });
}

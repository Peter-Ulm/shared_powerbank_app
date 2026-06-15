import 'dart:async';
import 'package:dio/dio.dart';
import '../../domain/models/order.dart';
import '../../domain/models/wallet.dart';
import '../../domain/repositories/orders_repository.dart';

class HttpOrdersRepository implements OrdersRepository {
  HttpOrdersRepository(this._dio);
  final Dio _dio;

  @override
  Future<Order> create({
    required String cabinetId,
    required int qty,
    Wallet? wallet,
    required String idempotencyKey,
  }) async {
    final res = await _dio.post(
      '/orders',
      data: {'cabinetId': cabinetId, 'qty': qty, if (wallet != null) 'wallet': wallet.name},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return _parseOrder((res.data as Map).cast<String, dynamic>());
  }

  @override
  Future<Order> byId(String id) async {
    final res = await _dio.get('/orders/$id');
    return _parseOrder((res.data as Map).cast<String, dynamic>());
  }

  @override
  Stream<Order> watch(String id) async* {
    while (true) {
      final order = await byId(id);
      yield order;
      const terminal = {
        OrderStatus.fulfilled, OrderStatus.partiallyFulfilled, OrderStatus.failed,
        OrderStatus.expired, OrderStatus.cancelled, OrderStatus.refunded,
      };
      if (terminal.contains(order.status)) break;
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Future<void> repush(String id) async {
    await _dio.post('/orders/$id/repush');
  }

  @override
  Future<void> cancel(String id) async {
    await _dio.post('/orders/$id/cancel');
  }

  /// Accepts either the canonical `id` field or the create response's `orderId`.
  Order _parseOrder(Map<String, dynamic> json) {
    final normalized = {...json};
    if (!normalized.containsKey('id') && normalized.containsKey('orderId')) {
      normalized['id'] = normalized['orderId'];
    }
    normalized['amountTzs'] ??= normalized['amount_tzs'] ?? 0;
    normalized['fulfilment'] ??= const [];
    return Order.fromJson(normalized);
  }
}

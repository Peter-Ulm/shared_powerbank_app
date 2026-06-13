import '../models/order.dart';
import '../models/wallet.dart';

abstract class OrdersRepository {
  Future<Order> create({
    required String cabinetId,
    required int qty,
    Wallet? wallet,
    required String idempotencyKey,
  });
  Future<Order> byId(String id);
  Stream<Order> watch(String id);
  Future<void> repush(String id);
  Future<void> cancel(String id);
}

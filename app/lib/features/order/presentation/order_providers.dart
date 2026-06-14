import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/order.dart';

/// Streams an order's live status from the (mock) backend.
final orderStreamProvider = StreamProvider.family<Order, String>((ref, id) {
  return ref.read(ordersRepositoryProvider).watch(id);
});

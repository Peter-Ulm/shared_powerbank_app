import 'package:freezed_annotation/freezed_annotation.dart';
part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus {
  @JsonValue('created') created,
  @JsonValue('payment_pending') paymentPending,
  @JsonValue('paid') paid,
  @JsonValue('fulfilling') fulfilling,
  @JsonValue('fulfilled') fulfilled,
  @JsonValue('partially_fulfilled') partiallyFulfilled,
  @JsonValue('expired') expired,
  @JsonValue('cancelled') cancelled,
  @JsonValue('refund_pending') refundPending,
  @JsonValue('refunded') refunded,
  @JsonValue('failed') failed,
}

enum FulfilmentStatus {
  @JsonValue('pending') pending,
  @JsonValue('ejecting') ejecting,
  @JsonValue('ejected') ejected,
  @JsonValue('failed') failed,
  @JsonValue('refunded') refunded,
}

@freezed
class FulfilmentUnit with _$FulfilmentUnit {
  const factory FulfilmentUnit({
    required int unit,
    required FulfilmentStatus status,
    int? slot,
  }) = _FulfilmentUnit;
  factory FulfilmentUnit.fromJson(Map<String, dynamic> json) => _$FulfilmentUnitFromJson(json);
}

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required OrderStatus status,
    required int amountTzs,
    @Default(<FulfilmentUnit>[]) List<FulfilmentUnit> fulfilment,
    String? payInstructions,
  }) = _Order;
  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

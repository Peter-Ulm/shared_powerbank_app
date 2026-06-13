// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FulfilmentUnitImpl _$$FulfilmentUnitImplFromJson(Map<String, dynamic> json) =>
    _$FulfilmentUnitImpl(
      unit: (json['unit'] as num).toInt(),
      status: $enumDecode(_$FulfilmentStatusEnumMap, json['status']),
      slot: (json['slot'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$FulfilmentUnitImplToJson(
  _$FulfilmentUnitImpl instance,
) => <String, dynamic>{
  'unit': instance.unit,
  'status': _$FulfilmentStatusEnumMap[instance.status]!,
  'slot': instance.slot,
};

const _$FulfilmentStatusEnumMap = {
  FulfilmentStatus.pending: 'pending',
  FulfilmentStatus.ejecting: 'ejecting',
  FulfilmentStatus.ejected: 'ejected',
  FulfilmentStatus.failed: 'failed',
  FulfilmentStatus.refunded: 'refunded',
};

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: json['id'] as String,
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  amountTzs: (json['amountTzs'] as num).toInt(),
  fulfilment:
      (json['fulfilment'] as List<dynamic>?)
          ?.map((e) => FulfilmentUnit.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FulfilmentUnit>[],
  payInstructions: json['payInstructions'] as String?,
);

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'amountTzs': instance.amountTzs,
      'fulfilment': instance.fulfilment,
      'payInstructions': instance.payInstructions,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.created: 'created',
  OrderStatus.paymentPending: 'payment_pending',
  OrderStatus.paid: 'paid',
  OrderStatus.fulfilling: 'fulfilling',
  OrderStatus.fulfilled: 'fulfilled',
  OrderStatus.partiallyFulfilled: 'partially_fulfilled',
  OrderStatus.expired: 'expired',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.refundPending: 'refund_pending',
  OrderStatus.refunded: 'refunded',
  OrderStatus.failed: 'failed',
};

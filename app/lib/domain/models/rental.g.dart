// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RentalImpl _$$RentalImplFromJson(Map<String, dynamic> json) => _$RentalImpl(
  id: json['id'] as String,
  powerbankId: json['powerbankId'] as String,
  status: $enumDecode(_$RentalStatusEnumMap, json['status']),
  startedAt: DateTime.parse(json['startedAt'] as String),
  dueAt: DateTime.parse(json['dueAt'] as String),
  overageTzs: (json['overageTzs'] as num?)?.toInt() ?? 0,
  returnedAt: json['returnedAt'] == null
      ? null
      : DateTime.parse(json['returnedAt'] as String),
  cabinetOutId: json['cabinetOutId'] as String?,
);

Map<String, dynamic> _$$RentalImplToJson(_$RentalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'powerbankId': instance.powerbankId,
      'status': _$RentalStatusEnumMap[instance.status]!,
      'startedAt': instance.startedAt.toIso8601String(),
      'dueAt': instance.dueAt.toIso8601String(),
      'overageTzs': instance.overageTzs,
      'returnedAt': instance.returnedAt?.toIso8601String(),
      'cabinetOutId': instance.cabinetOutId,
    };

const _$RentalStatusEnumMap = {
  RentalStatus.active: 'active',
  RentalStatus.completed: 'completed',
  RentalStatus.overdue: 'overdue',
  RentalStatus.lost: 'lost',
  RentalStatus.disputed: 'disputed',
  RentalStatus.closedByAdmin: 'closed_by_admin',
};

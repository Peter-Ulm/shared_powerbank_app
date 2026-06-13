// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cabinet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CabinetImpl _$$CabinetImplFromJson(Map<String, dynamic> json) =>
    _$CabinetImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      banksAvailable: (json['banksAvailable'] as num).toInt(),
      freeSlots: (json['freeSlots'] as num).toInt(),
      online: json['online'] as bool,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      unitPriceTzs: (json['unitPriceTzs'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CabinetImplToJson(_$CabinetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'banksAvailable': instance.banksAvailable,
      'freeSlots': instance.freeSlots,
      'online': instance.online,
      'lat': instance.lat,
      'lng': instance.lng,
      'distanceMeters': instance.distanceMeters,
      'unitPriceTzs': instance.unitPriceTzs,
    };

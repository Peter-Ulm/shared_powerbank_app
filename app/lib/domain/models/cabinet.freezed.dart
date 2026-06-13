// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cabinet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Cabinet _$CabinetFromJson(Map<String, dynamic> json) {
  return _Cabinet.fromJson(json);
}

/// @nodoc
mixin _$Cabinet {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  int get banksAvailable => throw _privateConstructorUsedError;
  int get freeSlots => throw _privateConstructorUsedError;
  bool get online => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  double? get distanceMeters => throw _privateConstructorUsedError;
  int? get unitPriceTzs => throw _privateConstructorUsedError;

  /// Serializes this Cabinet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Cabinet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CabinetCopyWith<Cabinet> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CabinetCopyWith<$Res> {
  factory $CabinetCopyWith(Cabinet value, $Res Function(Cabinet) then) =
      _$CabinetCopyWithImpl<$Res, Cabinet>;
  @useResult
  $Res call({
    String id,
    String label,
    int banksAvailable,
    int freeSlots,
    bool online,
    double lat,
    double lng,
    double? distanceMeters,
    int? unitPriceTzs,
  });
}

/// @nodoc
class _$CabinetCopyWithImpl<$Res, $Val extends Cabinet>
    implements $CabinetCopyWith<$Res> {
  _$CabinetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cabinet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? banksAvailable = null,
    Object? freeSlots = null,
    Object? online = null,
    Object? lat = null,
    Object? lng = null,
    Object? distanceMeters = freezed,
    Object? unitPriceTzs = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            banksAvailable: null == banksAvailable
                ? _value.banksAvailable
                : banksAvailable // ignore: cast_nullable_to_non_nullable
                      as int,
            freeSlots: null == freeSlots
                ? _value.freeSlots
                : freeSlots // ignore: cast_nullable_to_non_nullable
                      as int,
            online: null == online
                ? _value.online
                : online // ignore: cast_nullable_to_non_nullable
                      as bool,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            distanceMeters: freezed == distanceMeters
                ? _value.distanceMeters
                : distanceMeters // ignore: cast_nullable_to_non_nullable
                      as double?,
            unitPriceTzs: freezed == unitPriceTzs
                ? _value.unitPriceTzs
                : unitPriceTzs // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CabinetImplCopyWith<$Res> implements $CabinetCopyWith<$Res> {
  factory _$$CabinetImplCopyWith(
    _$CabinetImpl value,
    $Res Function(_$CabinetImpl) then,
  ) = __$$CabinetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String label,
    int banksAvailable,
    int freeSlots,
    bool online,
    double lat,
    double lng,
    double? distanceMeters,
    int? unitPriceTzs,
  });
}

/// @nodoc
class __$$CabinetImplCopyWithImpl<$Res>
    extends _$CabinetCopyWithImpl<$Res, _$CabinetImpl>
    implements _$$CabinetImplCopyWith<$Res> {
  __$$CabinetImplCopyWithImpl(
    _$CabinetImpl _value,
    $Res Function(_$CabinetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Cabinet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? banksAvailable = null,
    Object? freeSlots = null,
    Object? online = null,
    Object? lat = null,
    Object? lng = null,
    Object? distanceMeters = freezed,
    Object? unitPriceTzs = freezed,
  }) {
    return _then(
      _$CabinetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        banksAvailable: null == banksAvailable
            ? _value.banksAvailable
            : banksAvailable // ignore: cast_nullable_to_non_nullable
                  as int,
        freeSlots: null == freeSlots
            ? _value.freeSlots
            : freeSlots // ignore: cast_nullable_to_non_nullable
                  as int,
        online: null == online
            ? _value.online
            : online // ignore: cast_nullable_to_non_nullable
                  as bool,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        distanceMeters: freezed == distanceMeters
            ? _value.distanceMeters
            : distanceMeters // ignore: cast_nullable_to_non_nullable
                  as double?,
        unitPriceTzs: freezed == unitPriceTzs
            ? _value.unitPriceTzs
            : unitPriceTzs // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CabinetImpl implements _Cabinet {
  const _$CabinetImpl({
    required this.id,
    required this.label,
    required this.banksAvailable,
    required this.freeSlots,
    required this.online,
    required this.lat,
    required this.lng,
    this.distanceMeters,
    this.unitPriceTzs,
  });

  factory _$CabinetImpl.fromJson(Map<String, dynamic> json) =>
      _$$CabinetImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final int banksAvailable;
  @override
  final int freeSlots;
  @override
  final bool online;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final double? distanceMeters;
  @override
  final int? unitPriceTzs;

  @override
  String toString() {
    return 'Cabinet(id: $id, label: $label, banksAvailable: $banksAvailable, freeSlots: $freeSlots, online: $online, lat: $lat, lng: $lng, distanceMeters: $distanceMeters, unitPriceTzs: $unitPriceTzs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CabinetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.banksAvailable, banksAvailable) ||
                other.banksAvailable == banksAvailable) &&
            (identical(other.freeSlots, freeSlots) ||
                other.freeSlots == freeSlots) &&
            (identical(other.online, online) || other.online == online) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.unitPriceTzs, unitPriceTzs) ||
                other.unitPriceTzs == unitPriceTzs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    banksAvailable,
    freeSlots,
    online,
    lat,
    lng,
    distanceMeters,
    unitPriceTzs,
  );

  /// Create a copy of Cabinet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CabinetImplCopyWith<_$CabinetImpl> get copyWith =>
      __$$CabinetImplCopyWithImpl<_$CabinetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CabinetImplToJson(this);
  }
}

abstract class _Cabinet implements Cabinet {
  const factory _Cabinet({
    required final String id,
    required final String label,
    required final int banksAvailable,
    required final int freeSlots,
    required final bool online,
    required final double lat,
    required final double lng,
    final double? distanceMeters,
    final int? unitPriceTzs,
  }) = _$CabinetImpl;

  factory _Cabinet.fromJson(Map<String, dynamic> json) = _$CabinetImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  int get banksAvailable;
  @override
  int get freeSlots;
  @override
  bool get online;
  @override
  double get lat;
  @override
  double get lng;
  @override
  double? get distanceMeters;
  @override
  int? get unitPriceTzs;

  /// Create a copy of Cabinet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CabinetImplCopyWith<_$CabinetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

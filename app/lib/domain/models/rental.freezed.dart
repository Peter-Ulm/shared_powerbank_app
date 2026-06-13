// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rental.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Rental _$RentalFromJson(Map<String, dynamic> json) {
  return _Rental.fromJson(json);
}

/// @nodoc
mixin _$Rental {
  String get id => throw _privateConstructorUsedError;
  String get powerbankId => throw _privateConstructorUsedError;
  RentalStatus get status => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime get dueAt => throw _privateConstructorUsedError;
  int get overageTzs => throw _privateConstructorUsedError;
  DateTime? get returnedAt => throw _privateConstructorUsedError;
  String? get cabinetOutId => throw _privateConstructorUsedError;

  /// Serializes this Rental to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Rental
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RentalCopyWith<Rental> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RentalCopyWith<$Res> {
  factory $RentalCopyWith(Rental value, $Res Function(Rental) then) =
      _$RentalCopyWithImpl<$Res, Rental>;
  @useResult
  $Res call({
    String id,
    String powerbankId,
    RentalStatus status,
    DateTime startedAt,
    DateTime dueAt,
    int overageTzs,
    DateTime? returnedAt,
    String? cabinetOutId,
  });
}

/// @nodoc
class _$RentalCopyWithImpl<$Res, $Val extends Rental>
    implements $RentalCopyWith<$Res> {
  _$RentalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Rental
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? powerbankId = null,
    Object? status = null,
    Object? startedAt = null,
    Object? dueAt = null,
    Object? overageTzs = null,
    Object? returnedAt = freezed,
    Object? cabinetOutId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            powerbankId: null == powerbankId
                ? _value.powerbankId
                : powerbankId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RentalStatus,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dueAt: null == dueAt
                ? _value.dueAt
                : dueAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            overageTzs: null == overageTzs
                ? _value.overageTzs
                : overageTzs // ignore: cast_nullable_to_non_nullable
                      as int,
            returnedAt: freezed == returnedAt
                ? _value.returnedAt
                : returnedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            cabinetOutId: freezed == cabinetOutId
                ? _value.cabinetOutId
                : cabinetOutId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RentalImplCopyWith<$Res> implements $RentalCopyWith<$Res> {
  factory _$$RentalImplCopyWith(
    _$RentalImpl value,
    $Res Function(_$RentalImpl) then,
  ) = __$$RentalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String powerbankId,
    RentalStatus status,
    DateTime startedAt,
    DateTime dueAt,
    int overageTzs,
    DateTime? returnedAt,
    String? cabinetOutId,
  });
}

/// @nodoc
class __$$RentalImplCopyWithImpl<$Res>
    extends _$RentalCopyWithImpl<$Res, _$RentalImpl>
    implements _$$RentalImplCopyWith<$Res> {
  __$$RentalImplCopyWithImpl(
    _$RentalImpl _value,
    $Res Function(_$RentalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Rental
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? powerbankId = null,
    Object? status = null,
    Object? startedAt = null,
    Object? dueAt = null,
    Object? overageTzs = null,
    Object? returnedAt = freezed,
    Object? cabinetOutId = freezed,
  }) {
    return _then(
      _$RentalImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        powerbankId: null == powerbankId
            ? _value.powerbankId
            : powerbankId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RentalStatus,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dueAt: null == dueAt
            ? _value.dueAt
            : dueAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        overageTzs: null == overageTzs
            ? _value.overageTzs
            : overageTzs // ignore: cast_nullable_to_non_nullable
                  as int,
        returnedAt: freezed == returnedAt
            ? _value.returnedAt
            : returnedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        cabinetOutId: freezed == cabinetOutId
            ? _value.cabinetOutId
            : cabinetOutId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RentalImpl implements _Rental {
  const _$RentalImpl({
    required this.id,
    required this.powerbankId,
    required this.status,
    required this.startedAt,
    required this.dueAt,
    this.overageTzs = 0,
    this.returnedAt,
    this.cabinetOutId,
  });

  factory _$RentalImpl.fromJson(Map<String, dynamic> json) =>
      _$$RentalImplFromJson(json);

  @override
  final String id;
  @override
  final String powerbankId;
  @override
  final RentalStatus status;
  @override
  final DateTime startedAt;
  @override
  final DateTime dueAt;
  @override
  @JsonKey()
  final int overageTzs;
  @override
  final DateTime? returnedAt;
  @override
  final String? cabinetOutId;

  @override
  String toString() {
    return 'Rental(id: $id, powerbankId: $powerbankId, status: $status, startedAt: $startedAt, dueAt: $dueAt, overageTzs: $overageTzs, returnedAt: $returnedAt, cabinetOutId: $cabinetOutId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RentalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.powerbankId, powerbankId) ||
                other.powerbankId == powerbankId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.dueAt, dueAt) || other.dueAt == dueAt) &&
            (identical(other.overageTzs, overageTzs) ||
                other.overageTzs == overageTzs) &&
            (identical(other.returnedAt, returnedAt) ||
                other.returnedAt == returnedAt) &&
            (identical(other.cabinetOutId, cabinetOutId) ||
                other.cabinetOutId == cabinetOutId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    powerbankId,
    status,
    startedAt,
    dueAt,
    overageTzs,
    returnedAt,
    cabinetOutId,
  );

  /// Create a copy of Rental
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RentalImplCopyWith<_$RentalImpl> get copyWith =>
      __$$RentalImplCopyWithImpl<_$RentalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RentalImplToJson(this);
  }
}

abstract class _Rental implements Rental {
  const factory _Rental({
    required final String id,
    required final String powerbankId,
    required final RentalStatus status,
    required final DateTime startedAt,
    required final DateTime dueAt,
    final int overageTzs,
    final DateTime? returnedAt,
    final String? cabinetOutId,
  }) = _$RentalImpl;

  factory _Rental.fromJson(Map<String, dynamic> json) = _$RentalImpl.fromJson;

  @override
  String get id;
  @override
  String get powerbankId;
  @override
  RentalStatus get status;
  @override
  DateTime get startedAt;
  @override
  DateTime get dueAt;
  @override
  int get overageTzs;
  @override
  DateTime? get returnedAt;
  @override
  String? get cabinetOutId;

  /// Create a copy of Rental
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RentalImplCopyWith<_$RentalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

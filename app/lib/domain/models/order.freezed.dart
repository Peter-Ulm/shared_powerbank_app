// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FulfilmentUnit _$FulfilmentUnitFromJson(Map<String, dynamic> json) {
  return _FulfilmentUnit.fromJson(json);
}

/// @nodoc
mixin _$FulfilmentUnit {
  int get unit => throw _privateConstructorUsedError;
  FulfilmentStatus get status => throw _privateConstructorUsedError;
  int? get slot => throw _privateConstructorUsedError;

  /// Serializes this FulfilmentUnit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FulfilmentUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FulfilmentUnitCopyWith<FulfilmentUnit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FulfilmentUnitCopyWith<$Res> {
  factory $FulfilmentUnitCopyWith(
    FulfilmentUnit value,
    $Res Function(FulfilmentUnit) then,
  ) = _$FulfilmentUnitCopyWithImpl<$Res, FulfilmentUnit>;
  @useResult
  $Res call({int unit, FulfilmentStatus status, int? slot});
}

/// @nodoc
class _$FulfilmentUnitCopyWithImpl<$Res, $Val extends FulfilmentUnit>
    implements $FulfilmentUnitCopyWith<$Res> {
  _$FulfilmentUnitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FulfilmentUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unit = null,
    Object? status = null,
    Object? slot = freezed,
  }) {
    return _then(
      _value.copyWith(
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as FulfilmentStatus,
            slot: freezed == slot
                ? _value.slot
                : slot // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FulfilmentUnitImplCopyWith<$Res>
    implements $FulfilmentUnitCopyWith<$Res> {
  factory _$$FulfilmentUnitImplCopyWith(
    _$FulfilmentUnitImpl value,
    $Res Function(_$FulfilmentUnitImpl) then,
  ) = __$$FulfilmentUnitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int unit, FulfilmentStatus status, int? slot});
}

/// @nodoc
class __$$FulfilmentUnitImplCopyWithImpl<$Res>
    extends _$FulfilmentUnitCopyWithImpl<$Res, _$FulfilmentUnitImpl>
    implements _$$FulfilmentUnitImplCopyWith<$Res> {
  __$$FulfilmentUnitImplCopyWithImpl(
    _$FulfilmentUnitImpl _value,
    $Res Function(_$FulfilmentUnitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FulfilmentUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unit = null,
    Object? status = null,
    Object? slot = freezed,
  }) {
    return _then(
      _$FulfilmentUnitImpl(
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as FulfilmentStatus,
        slot: freezed == slot
            ? _value.slot
            : slot // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FulfilmentUnitImpl implements _FulfilmentUnit {
  const _$FulfilmentUnitImpl({
    required this.unit,
    required this.status,
    this.slot,
  });

  factory _$FulfilmentUnitImpl.fromJson(Map<String, dynamic> json) =>
      _$$FulfilmentUnitImplFromJson(json);

  @override
  final int unit;
  @override
  final FulfilmentStatus status;
  @override
  final int? slot;

  @override
  String toString() {
    return 'FulfilmentUnit(unit: $unit, status: $status, slot: $slot)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FulfilmentUnitImpl &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.slot, slot) || other.slot == slot));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, unit, status, slot);

  /// Create a copy of FulfilmentUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FulfilmentUnitImplCopyWith<_$FulfilmentUnitImpl> get copyWith =>
      __$$FulfilmentUnitImplCopyWithImpl<_$FulfilmentUnitImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FulfilmentUnitImplToJson(this);
  }
}

abstract class _FulfilmentUnit implements FulfilmentUnit {
  const factory _FulfilmentUnit({
    required final int unit,
    required final FulfilmentStatus status,
    final int? slot,
  }) = _$FulfilmentUnitImpl;

  factory _FulfilmentUnit.fromJson(Map<String, dynamic> json) =
      _$FulfilmentUnitImpl.fromJson;

  @override
  int get unit;
  @override
  FulfilmentStatus get status;
  @override
  int? get slot;

  /// Create a copy of FulfilmentUnit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FulfilmentUnitImplCopyWith<_$FulfilmentUnitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  String get id => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  int get amountTzs => throw _privateConstructorUsedError;
  List<FulfilmentUnit> get fulfilment => throw _privateConstructorUsedError;
  String? get payInstructions => throw _privateConstructorUsedError;

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call({
    String id,
    OrderStatus status,
    int amountTzs,
    List<FulfilmentUnit> fulfilment,
    String? payInstructions,
  });
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? amountTzs = null,
    Object? fulfilment = null,
    Object? payInstructions = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            amountTzs: null == amountTzs
                ? _value.amountTzs
                : amountTzs // ignore: cast_nullable_to_non_nullable
                      as int,
            fulfilment: null == fulfilment
                ? _value.fulfilment
                : fulfilment // ignore: cast_nullable_to_non_nullable
                      as List<FulfilmentUnit>,
            payInstructions: freezed == payInstructions
                ? _value.payInstructions
                : payInstructions // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
    _$OrderImpl value,
    $Res Function(_$OrderImpl) then,
  ) = __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    OrderStatus status,
    int amountTzs,
    List<FulfilmentUnit> fulfilment,
    String? payInstructions,
  });
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
    _$OrderImpl _value,
    $Res Function(_$OrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? amountTzs = null,
    Object? fulfilment = null,
    Object? payInstructions = freezed,
  }) {
    return _then(
      _$OrderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        amountTzs: null == amountTzs
            ? _value.amountTzs
            : amountTzs // ignore: cast_nullable_to_non_nullable
                  as int,
        fulfilment: null == fulfilment
            ? _value._fulfilment
            : fulfilment // ignore: cast_nullable_to_non_nullable
                  as List<FulfilmentUnit>,
        payInstructions: freezed == payInstructions
            ? _value.payInstructions
            : payInstructions // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl implements _Order {
  const _$OrderImpl({
    required this.id,
    required this.status,
    required this.amountTzs,
    final List<FulfilmentUnit> fulfilment = const <FulfilmentUnit>[],
    this.payInstructions,
  }) : _fulfilment = fulfilment;

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final String id;
  @override
  final OrderStatus status;
  @override
  final int amountTzs;
  final List<FulfilmentUnit> _fulfilment;
  @override
  @JsonKey()
  List<FulfilmentUnit> get fulfilment {
    if (_fulfilment is EqualUnmodifiableListView) return _fulfilment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fulfilment);
  }

  @override
  final String? payInstructions;

  @override
  String toString() {
    return 'Order(id: $id, status: $status, amountTzs: $amountTzs, fulfilment: $fulfilment, payInstructions: $payInstructions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amountTzs, amountTzs) ||
                other.amountTzs == amountTzs) &&
            const DeepCollectionEquality().equals(
              other._fulfilment,
              _fulfilment,
            ) &&
            (identical(other.payInstructions, payInstructions) ||
                other.payInstructions == payInstructions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    status,
    amountTzs,
    const DeepCollectionEquality().hash(_fulfilment),
    payInstructions,
  );

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(this);
  }
}

abstract class _Order implements Order {
  const factory _Order({
    required final String id,
    required final OrderStatus status,
    required final int amountTzs,
    final List<FulfilmentUnit> fulfilment,
    final String? payInstructions,
  }) = _$OrderImpl;

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  String get id;
  @override
  OrderStatus get status;
  @override
  int get amountTzs;
  @override
  List<FulfilmentUnit> get fulfilment;
  @override
  String? get payInstructions;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

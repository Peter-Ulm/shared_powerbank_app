import 'package:freezed_annotation/freezed_annotation.dart';
part 'rental.freezed.dart';
part 'rental.g.dart';

enum RentalStatus {
  @JsonValue('active') active,
  @JsonValue('completed') completed,
  @JsonValue('overdue') overdue,
  @JsonValue('lost') lost,
  @JsonValue('disputed') disputed,
  @JsonValue('closed_by_admin') closedByAdmin,
}

@freezed
class Rental with _$Rental {
  const factory Rental({
    required String id,
    required String powerbankId,
    required RentalStatus status,
    required DateTime startedAt,
    required DateTime dueAt,
    @Default(0) int overageTzs,
    DateTime? returnedAt,
    String? cabinetOutId,
  }) = _Rental;
  factory Rental.fromJson(Map<String, dynamic> json) => _$RentalFromJson(json);
}

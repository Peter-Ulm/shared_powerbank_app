import 'package:freezed_annotation/freezed_annotation.dart';
part 'cabinet.freezed.dart';
part 'cabinet.g.dart';

@freezed
class Cabinet with _$Cabinet {
  const factory Cabinet({
    required String id,
    required String label,
    required int banksAvailable,
    required int freeSlots,
    required bool online,
    required double lat,
    required double lng,
    double? distanceMeters,
    int? unitPriceTzs,
  }) = _Cabinet;
  factory Cabinet.fromJson(Map<String, dynamic> json) => _$CabinetFromJson(json);
}

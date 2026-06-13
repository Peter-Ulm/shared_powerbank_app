import 'package:json_annotation/json_annotation.dart';

enum Wallet {
  @JsonValue('mpesa') mpesa,
  @JsonValue('mixx') mixx,
  @JsonValue('airtel') airtel,
  @JsonValue('halopesa') halopesa,
}

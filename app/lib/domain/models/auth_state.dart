import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth.dart';
part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unknown() = AuthUnknown;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.otpSent({required String phone}) = AuthOtpSent;
  const factory AuthState.authenticated({required AppUser user}) = AuthAuthenticated;
}

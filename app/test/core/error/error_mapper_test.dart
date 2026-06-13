import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/error/app_exception.dart';
import 'package:marijoy_app/core/error/error_mapper.dart';

void main() {
  test('maps known code to swahili and english messages', () {
    const ex = AppException(code: 'CABINET_OFFLINE');
    expect(ErrorMapper.message(ex, 'sw'), isNotEmpty);
    expect(ErrorMapper.message(ex, 'en'), 'This cabinet is offline. Try another nearby.');
    expect(ErrorMapper.message(ex, 'sw'), isNot(ErrorMapper.message(ex, 'en')));
  });
  test('unknown code falls back to generic message', () {
    const ex = AppException(code: 'SOMETHING_NEW');
    expect(ErrorMapper.message(ex, 'en'), 'Something went wrong. Please try again.');
  });
  test('network exception maps to connectivity message', () {
    const ex = AppException(code: AppException.networkCode);
    expect(ErrorMapper.message(ex, 'en'), 'No connection. Check your internet and retry.');
  });
}

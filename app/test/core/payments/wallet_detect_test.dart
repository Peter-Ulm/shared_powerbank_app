import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/payments/wallet_detect.dart';
import 'package:marijoy_app/domain/models/wallet.dart';

void main() {
  test('detects wallet by prefix', () {
    expect(detectWallet('+255712345678'), Wallet.mixx);
    expect(detectWallet('+255745000000'), Wallet.mpesa);
    expect(detectWallet('+255682000000'), Wallet.airtel);
    expect(detectWallet('+255612000000'), Wallet.halopesa);
  });
  test('returns null for unknown prefix or bad input', () {
    expect(detectWallet('+255500000000'), isNull);
    expect(detectWallet('garbage'), isNull);
  });
}

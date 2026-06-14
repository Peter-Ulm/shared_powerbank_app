import '../../domain/models/wallet.dart';

/// Maps a TZS E.164 MSISDN (+255XXXXXXXXX) to its default mobile-money wallet
/// by the 2-digit national prefix. Configurable map; user can always override.
/// (Prefixes per docs/payments-tanzania.md §3.)
const Map<String, Wallet> kWalletPrefixes = {
  '74': Wallet.mpesa, '75': Wallet.mpesa, '76': Wallet.mpesa,
  '65': Wallet.mixx, '67': Wallet.mixx, '71': Wallet.mixx,
  '68': Wallet.airtel, '69': Wallet.airtel, '78': Wallet.airtel,
  '61': Wallet.halopesa, '62': Wallet.halopesa,
};

Wallet? detectWallet(String e164) {
  final m = RegExp(r'^\+255(\d{2})').firstMatch(e164);
  if (m == null) return null;
  return kWalletPrefixes[m.group(1)];
}

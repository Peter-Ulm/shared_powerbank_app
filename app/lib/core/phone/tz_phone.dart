/// Tanzania MSISDN normalization to E.164 (+255XXXXXXXXX, 9 national digits).
/// Lightweight, dependency-free; a fuller libphonenumber can replace it later.
class TzPhone {
  static String? normalize(String input) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('255')) {
      digits = digits.substring(3);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length != 9) return null;
    if (!RegExp(r'^[67]\d{8}$').hasMatch(digits)) return null;
    return '+255$digits';
  }

  static bool isValid(String input) => normalize(input) != null;
}

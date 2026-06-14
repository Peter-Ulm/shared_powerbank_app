/// Formats an integer TZS amount as 'TZS 1,000' (no decimals; thousands grouped).
String formatTzs(int amount) {
  final neg = amount < 0;
  final s = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return 'TZS ${neg ? '-' : ''}$buf';
}

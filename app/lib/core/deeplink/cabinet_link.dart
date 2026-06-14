/// Extracts a cabinet deviceId from a scanned QR string or deep link.
/// Accepts: 'https://<host>/c/{id}', '/c/{id}', or a bare '{id}'.
/// Device codes are alphanumeric (3–32 chars); returned upper-cased.
String? parseCabinetId(String input) {
  final raw = input.trim();
  if (raw.isEmpty) return null;

  String candidate = raw;
  final uri = Uri.tryParse(raw);
  if (uri != null && uri.pathSegments.isNotEmpty) {
    final segs = uri.pathSegments;
    final i = segs.indexOf('c');
    if (i != -1 && i + 1 < segs.length) {
      candidate = segs[i + 1];
    } else if (raw.contains('/')) {
      // A path/URL without a /c/{id} segment is not a cabinet link.
      return null;
    }
  }

  candidate = candidate.toUpperCase();
  if (RegExp(r'^[A-Z0-9]{3,32}$').hasMatch(candidate)) return candidate;
  return null;
}

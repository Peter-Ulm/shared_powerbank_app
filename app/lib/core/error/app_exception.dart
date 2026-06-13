class AppException implements Exception {
  const AppException({required this.code, this.serverMessage, this.details});
  static const String networkCode = 'NETWORK_ERROR';
  static const String unknownCode = 'UNKNOWN';
  final String code;
  final String? serverMessage;
  final Map<String, dynamic>? details;
  @override
  String toString() => 'AppException($code)';
}

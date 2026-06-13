import 'app_exception.dart';

class ErrorMapper {
  static const Map<String, Map<String, String>> _messages = {
    'CABINET_OFFLINE': {
      'sw': 'Cabinet hii haipo mtandaoni. Jaribu nyingine karibu nawe.',
      'en': 'This cabinet is offline. Try another nearby.',
    },
    'INSUFFICIENT_BANKS': {
      'sw': 'Hakuna benki za kutosha kwa sasa. Punguza idadi au jaribu cabinet nyingine.',
      'en': 'Not enough power banks right now. Lower the quantity or try another cabinet.',
    },
    'PAYMENT_TIMEOUT': {
      'sw': 'Muda wa malipo umeisha. Tuma ombi tena.',
      'en': 'The payment prompt expired. Resend it to try again.',
    },
    'USER_BLOCKED': {
      'sw': 'Akaunti yako imezuiwa. Lipa deni lililobaki ili kuendelea.',
      'en': 'Your account is blocked. Settle the outstanding balance to continue.',
    },
    AppException.networkCode: {
      'sw': 'Hakuna mtandao. Angalia intaneti yako kisha jaribu tena.',
      'en': 'No connection. Check your internet and retry.',
    },
  };
  static const Map<String, String> _generic = {
    'sw': 'Hitilafu imetokea. Tafadhali jaribu tena.',
    'en': 'Something went wrong. Please try again.',
  };
  static String message(AppException ex, String locale) {
    final lang = locale == 'sw' ? 'sw' : 'en';
    final entry = _messages[ex.code] ?? _generic;
    return entry[lang] ?? _generic[lang]!;
  }
}

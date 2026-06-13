import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:marijoy_app/core/l10n/app_localizations.dart';

void main() {
  test('swahili and english are supported locales', () {
    expect(AppLocalizations.supportedLocales, contains(const Locale('sw')));
    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
  });

  testWidgets('resolves swahili payment string', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('sw'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox();
        }),
      ),
    );
    expect(l10n.payCheckPhone, 'Angalia simu yako, weka namba yako ya siri');
  });
}

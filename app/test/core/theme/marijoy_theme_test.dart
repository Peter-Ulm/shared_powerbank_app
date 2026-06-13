import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:marijoy_app/core/theme/marijoy_theme.dart';
import 'package:marijoy_app/core/theme/marijoy_colors.dart';

void main() {
  test('light theme uses Charge Green as primary and Inter font', () {
    final theme = MariJoyTheme.light();
    expect(theme.colorScheme.primary, MariJoyColors.chargeGreen);
    expect(theme.colorScheme.secondary, MariJoyColors.marigold);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(theme.useMaterial3, isTrue);
  });

  test('primary buttons are at least 56dp tall for tap targets', () {
    final theme = MariJoyTheme.light();
    final style = theme.filledButtonTheme.style!;
    final size = style.minimumSize!.resolve({})!;
    expect(size.height, greaterThanOrEqualTo(56));
  });
}

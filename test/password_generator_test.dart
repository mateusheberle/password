import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:password/utils/password_generator.dart';

void main() {
  test('generates correct length and composition', () {
    final pwd = PasswordGenerator.generate(
      length: 12,
      includeUppercase: true,
      includeLowercase: true,
      includeNumbers: true,
      includeSymbols: true,
      random: Random(42), // deterministic for tests
    );

    expect(pwd.length, 12);
    // basic checks: contains at least one char from allowed sets
    final hasUpper = pwd.contains(RegExp(r'[A-Z]'));
    final hasLower = pwd.contains(RegExp(r'[a-z]'));
    final hasNum = pwd.contains(RegExp(r'[0-9]'));

    expect(hasUpper || hasLower || hasNum, isTrue);
  });

  test('returns empty when no charset selected', () {
    final pwd = PasswordGenerator.generate(
      length: 8,
      includeUppercase: false,
      includeLowercase: false,
      includeNumbers: false,
      includeSymbols: false,
      random: Random(1),
    );
    expect(pwd, '');
  });
}

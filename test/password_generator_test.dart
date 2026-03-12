import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:password/utils/password_generator.dart';

void main() {
  group('PasswordGenerator', () {
    group('length', () {
      test('generates password with exact requested length', () {
        for (final len in [1, 4, 8, 12, 20, 64, 128]) {
          final pwd = PasswordGenerator.generate(
            length: len,
            random: Random(42),
          );
          expect(pwd.length, len, reason: 'Expected length $len');
        }
      });

      test('generates empty string for length 0', () {
        final pwd = PasswordGenerator.generate(length: 0, random: Random(1));
        expect(pwd, '');
      });
    });

    group('character sets', () {
      test('only uppercase when other sets disabled', () {
        final pwd = PasswordGenerator.generate(
          length: 50,
          includeUppercase: true,
          includeLowercase: false,
          includeNumbers: false,
          includeSymbols: false,
          random: Random(42),
        );
        expect(pwd, matches(RegExp(r'^[A-Z]+$')));
      });

      test('only lowercase when other sets disabled', () {
        final pwd = PasswordGenerator.generate(
          length: 50,
          includeUppercase: false,
          includeLowercase: true,
          includeNumbers: false,
          includeSymbols: false,
          random: Random(42),
        );
        expect(pwd, matches(RegExp(r'^[a-z]+$')));
      });

      test('only numbers when other sets disabled', () {
        final pwd = PasswordGenerator.generate(
          length: 50,
          includeUppercase: false,
          includeLowercase: false,
          includeNumbers: true,
          includeSymbols: false,
          random: Random(42),
        );
        expect(pwd, matches(RegExp(r'^[0-9]+$')));
      });

      test('only symbols when other sets disabled', () {
        final pwd = PasswordGenerator.generate(
          length: 50,
          includeUppercase: false,
          includeLowercase: false,
          includeNumbers: false,
          includeSymbols: true,
          random: Random(42),
        );
        expect(pwd.length, 50);
        // Should contain no letters or digits
        expect(pwd.contains(RegExp(r'[a-zA-Z0-9]')), isFalse);
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

      test('combines uppercase and numbers correctly', () {
        final pwd = PasswordGenerator.generate(
          length: 100,
          includeUppercase: true,
          includeLowercase: false,
          includeNumbers: true,
          includeSymbols: false,
          random: Random(42),
        );
        expect(pwd, matches(RegExp(r'^[A-Z0-9]+$')));
      });

      test('combines lowercase and symbols correctly', () {
        final pwd = PasswordGenerator.generate(
          length: 100,
          includeUppercase: false,
          includeLowercase: true,
          includeNumbers: false,
          includeSymbols: true,
          random: Random(42),
        );
        expect(pwd.length, 100);
        expect(pwd.contains(RegExp(r'[A-Z0-9]')), isFalse);
      });

      test('all charsets enabled produces mixed output', () {
        final pwd = PasswordGenerator.generate(
          length: 200,
          includeUppercase: true,
          includeLowercase: true,
          includeNumbers: true,
          includeSymbols: true,
          random: Random(42),
        );
        expect(pwd.length, 200);
        expect(pwd.contains(RegExp(r'[A-Z]')), isTrue);
        expect(pwd.contains(RegExp(r'[a-z]')), isTrue);
        expect(pwd.contains(RegExp(r'[0-9]')), isTrue);
      });
    });

    group('determinism', () {
      test('same seed produces same password', () {
        final pwd1 = PasswordGenerator.generate(
          length: 20,
          random: Random(99),
        );
        final pwd2 = PasswordGenerator.generate(
          length: 20,
          random: Random(99),
        );
        expect(pwd1, pwd2);
      });

      test('different seeds produce different passwords', () {
        final pwd1 = PasswordGenerator.generate(
          length: 20,
          random: Random(1),
        );
        final pwd2 = PasswordGenerator.generate(
          length: 20,
          random: Random(2),
        );
        expect(pwd1, isNot(pwd2));
      });
    });

    group('defaults', () {
      test('default parameters include all charsets', () {
        final pwd = PasswordGenerator.generate(
          length: 200,
          random: Random(42),
        );
        expect(pwd.contains(RegExp(r'[A-Z]')), isTrue);
        expect(pwd.contains(RegExp(r'[a-z]')), isTrue);
        expect(pwd.contains(RegExp(r'[0-9]')), isTrue);
      });

      test('works with secure random (no seed)', () {
        final pwd = PasswordGenerator.generate(length: 16);
        expect(pwd.length, 16);
      });
    });

    group('edge cases', () {
      test('length 1 with all charsets returns single char', () {
        final pwd = PasswordGenerator.generate(
          length: 1,
          random: Random(42),
        );
        expect(pwd.length, 1);
      });

      test('very long password (1000 chars)', () {
        final pwd = PasswordGenerator.generate(
          length: 1000,
          random: Random(42),
        );
        expect(pwd.length, 1000);
      });

      test('password contains only valid characters from selected sets', () {
        const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        const lower = 'abcdefghijklmnopqrstuvwxyz';
        const nums = '0123456789';
        final allValid = upper + lower + nums;

        final pwd = PasswordGenerator.generate(
          length: 500,
          includeUppercase: true,
          includeLowercase: true,
          includeNumbers: true,
          includeSymbols: false,
          random: Random(42),
        );

        for (final char in pwd.split('')) {
          expect(allValid.contains(char), isTrue,
              reason: 'Character "$char" should be in allowed set');
        }
      });

      test('symbols set contains expected special characters', () {
        final pwd = PasswordGenerator.generate(
          length: 5000,
          includeUppercase: false,
          includeLowercase: false,
          includeNumbers: false,
          includeSymbols: true,
          random: Random(42),
        );
        // Should contain various symbols
        expect(pwd.contains('!'), isTrue);
        expect(pwd.contains('@'), isTrue);
        expect(pwd.contains('#'), isTrue);
      });

      test('all single-charset combinations produce valid output', () {
        final configs = [
          {'upper': true, 'lower': false, 'nums': false, 'syms': false},
          {'upper': false, 'lower': true, 'nums': false, 'syms': false},
          {'upper': false, 'lower': false, 'nums': true, 'syms': false},
          {'upper': false, 'lower': false, 'nums': false, 'syms': true},
        ];

        for (final config in configs) {
          final pwd = PasswordGenerator.generate(
            length: 20,
            includeUppercase: config['upper']!,
            includeLowercase: config['lower']!,
            includeNumbers: config['nums']!,
            includeSymbols: config['syms']!,
            random: Random(42),
          );
          expect(pwd.length, 20,
              reason: 'Config $config should produce 20 chars');
        }
      });

      test('multiple sequential generations are independent', () {
        final passwords = <String>{};
        for (var i = 0; i < 50; i++) {
          final pwd = PasswordGenerator.generate(
            length: 16,
            random: Random(i),
          );
          passwords.add(pwd);
        }
        // With 50 different seeds, we should get at least 45 unique passwords
        expect(passwords.length, greaterThan(45));
      });
    });
  });
}

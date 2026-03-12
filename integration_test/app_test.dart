import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:password/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App startup', () {
    testWidgets('app launches and shows home page', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      expect(find.text('Password Generator'), findsOneWidget);
      expect(find.text('GERAR SENHA'), findsOneWidget);
      expect(find.text('Sua senha aparecerá aqui.'), findsOneWidget);
    });
  });

  group('Password generation flow', () {
    testWidgets('generate password with all options enabled', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // All switches should be ON by default
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.length, 4);
      for (final s in switches) {
        expect(s.value, isTrue);
      }

      // Tap generate
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      // Placeholder should disappear
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });

    testWidgets('generate only numeric password', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Disable uppercase, lowercase, symbols - keep only numbers
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      // Verify switch states
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isFalse); // uppercase OFF
      expect(switches[1].value, isFalse); // lowercase OFF
      expect(switches[2].value, isTrue); // numbers ON
      expect(switches[3].value, isFalse); // symbols OFF

      // Generate
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });

    testWidgets('generate password multiple times', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Generate first password
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);

      // Generate second password
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);

      // Generate third password
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });
  });

  group('Error handling flow', () {
    testWidgets('shows error when no charset selected', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Disable all switches
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir números'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      // Try to generate
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.text('Selecione pelo menos uma opção.'), findsOneWidget);

      // Password placeholder should still be there
      expect(find.text('Sua senha aparecerá aqui.'), findsOneWidget);
    });

    testWidgets('recovers from error by enabling a charset', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Disable all switches
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir números'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      // Try to generate -> error
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Selecione pelo menos uma opção.'), findsOneWidget);

      // Wait for snackbar to dismiss
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Re-enable uppercase
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();

      // Generate successfully
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });
  });

  group('Copy to clipboard flow', () {
    testWidgets('shows error icon when copying without password',
        (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Tap copy before generating
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      // Should show error snackbar
      expect(
        find.text("Pressione 'Gerar Senha' para gerar uma nova senha."),
        findsOneWidget,
      );

      // Should show error icon
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Wait for timer to complete
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Icon should reset
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('copies generated password successfully', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Generate password first
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      // Tap copy
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      // Should show success
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(
        find.text('Texto copiado para a área de transferência!'),
        findsOneWidget,
      );

      // Wait for reset
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });
  });

  group('Switch toggle flows', () {
    testWidgets('toggle each switch individually and generate', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Toggle uppercase OFF, generate
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);

      // Toggle uppercase back ON, toggle lowercase OFF, generate
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });

    testWidgets('toggle all switches off and on rapidly', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Toggle all OFF
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir números'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      // Verify all OFF
      var switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      for (final s in switches) {
        expect(s.value, isFalse);
      }

      // Toggle all back ON
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir números'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      // Verify all ON
      switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      for (final s in switches) {
        expect(s.value, isTrue);
      }

      // Generate should work
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });
  });

  group('Full end-to-end flow', () {
    testWidgets('generate, copy, and verify success', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // 1. App starts with placeholder
      expect(find.text('Sua senha aparecerá aqui.'), findsOneWidget);
      expect(find.text('Tamanho da senha: 20'), findsOneWidget);

      // 2. Disable symbols
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      // 3. Generate password
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);

      // 4. Copy password -> success icon
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Wait for icon timer + snackbar to fully dismiss
      await Future<void>.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 5. Re-enable symbols, generate again
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });

    testWidgets('error flow: no charset then recover', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // 1. Disable all switches
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir números'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      // 2. Try generate -> error snackbar
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Selecione pelo menos uma opção.'), findsOneWidget);

      // 3. Wait for snackbar to dismiss
      await Future<void>.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 4. Re-enable all and generate successfully
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir números'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });

    testWidgets('copy error when no password generated', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Tap copy without generating password
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      expect(
        find.text("Pressione 'Gerar Senha' para gerar uma nova senha."),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Wait for reset
      await Future<void>.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Icon should be back to copy
      expect(find.byIcon(Icons.copy), findsOneWidget);

      // Placeholder should still be there
      expect(find.text('Sua senha aparecerá aqui.'), findsOneWidget);
    });
  });
}

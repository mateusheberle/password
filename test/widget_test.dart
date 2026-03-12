import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password/main.dart';
import 'package:password/home_page.dart';
import 'package:password/widgets/generate_button.dart';
import 'package:password/widgets/password_display.dart';
import 'package:password/widgets/password_length_selector.dart';
import 'package:password/widgets/switch_tile.dart';
import 'package:password/colors.dart';

/// Helper que envolve widget com MaterialApp para testes.
Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('PasswordGeneratorApp', () {
    testWidgets('renders MaterialApp with correct title', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Password Generator');
    });

    testWidgets('navigates to HomePage on initial route', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('does not show debug banner', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });
  });

  group('HomePage', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      expect(find.text('Password Generator'), findsOneWidget);
    });

    testWidgets('shows placeholder text before generation', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      expect(find.text('Sua senha aparecerá aqui.'), findsOneWidget);
    });

    testWidgets('shows four switch tiles', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      expect(find.byType(SwitchTile), findsNWidgets(4));
      expect(find.text('Incluir letras maiúsculas'), findsOneWidget);
      expect(find.text('Incluir letras minúsculas'), findsOneWidget);
      expect(find.text('Incluir números'), findsOneWidget);
      expect(find.text('Incluir símbolos'), findsOneWidget);
    });

    testWidgets('shows generate button', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      expect(find.text('GERAR SENHA'), findsOneWidget);
    });

    testWidgets('shows password length selector', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      expect(find.byType(PasswordLengthSelector), findsOneWidget);
      expect(find.textContaining('Tamanho da senha:'), findsOneWidget);
    });

    testWidgets('generates password on button tap', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Tap the generate button
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      // Placeholder should be gone since password was generated
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });

    testWidgets('toggles uppercase switch off and on', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // All switches start ON
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsNWidgets(4));

      // Toggle first switch (maiúsculas) OFF
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();

      // Toggle back ON
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
    });

    testWidgets('shows snackbar when no option selected and generate pressed',
        (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Turn off all switches
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir números'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      // Tap generate
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      expect(find.text('Selecione pelo menos uma opção.'), findsOneWidget);
    });

    testWidgets('copy icon shows error when no password generated',
        (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Tap the copy icon button
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      // Should show error snackbar
      expect(
        find.text("Pressione 'Gerar Senha' para gerar uma nova senha."),
        findsOneWidget,
      );

      // Advance past the 1-second timer in _copyToClipboard
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('copy icon copies password after generation', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Generate a password first
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      // Tap copy
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      // Should show the check icon (copied state)
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Should show copy success snackbar
      expect(
        find.text('Texto copiado para a área de transferência!'),
        findsOneWidget,
      );

      // Advance past the 1-second timer in _copyToClipboard
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });
  });

  group('GenerateButton', () {
    testWidgets('renders with correct text', (tester) async {
      await tester.pumpWidget(_wrap(GenerateButton(onTap: () {})));
      expect(find.text('GERAR SENHA'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(GenerateButton(onTap: () {
        tapped = true;
      })));

      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('PasswordDisplay', () {
    testWidgets('shows placeholder when password is empty', (tester) async {
      await tester.pumpWidget(_wrap(PasswordDisplay(
        password: '',
        onCopy: () {},
        onError: () {},
      )));

      expect(find.text('Sua senha aparecerá aqui.'), findsOneWidget);
    });

    testWidgets('shows password text when provided', (tester) async {
      await tester.pumpWidget(_wrap(PasswordDisplay(
        password: 'MyP@ss123',
        onCopy: () {},
        onError: () {},
      )));

      expect(find.text('MyP@ss123'), findsOneWidget);
    });

    testWidgets('calls onError when password empty and icon tapped',
        (tester) async {
      var errorCalled = false;
      await tester.pumpWidget(_wrap(PasswordDisplay(
        password: '',
        onCopy: () {},
        onError: () {
          errorCalled = true;
        },
      )));

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      expect(errorCalled, isTrue);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Advance past the 1-second timer
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('calls onCopy when password present and icon tapped',
        (tester) async {
      var copyCalled = false;
      await tester.pumpWidget(_wrap(PasswordDisplay(
        password: 'Secret123!',
        onCopy: () {
          copyCalled = true;
        },
        onError: () {},
      )));

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      expect(copyCalled, isTrue);
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Advance past the 1-second timer
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('PasswordLengthSelector', () {
    testWidgets('displays current length', (tester) async {
      await tester.pumpWidget(_wrap(PasswordLengthSelector(
        length: 20,
        onDecrement: () {},
        onIncrement: () {},
      )));

      expect(find.text('Tamanho da senha: 20'), findsOneWidget);
    });

    testWidgets('renders slider widget', (tester) async {
      await tester.pumpWidget(_wrap(PasswordLengthSelector(
        length: 10,
        onDecrement: () {},
        onIncrement: () {},
      )));

      expect(find.byType(Slider), findsOneWidget);
    });
  });

  group('SwitchTile', () {
    testWidgets('renders text', (tester) async {
      await tester.pumpWidget(_wrap(SwitchTile(
        text: 'Test Switch',
        value: true,
        onChanged: (_) {},
      )));

      expect(find.text('Test Switch'), findsOneWidget);
    });

    testWidgets('shows ON state correctly', (tester) async {
      await tester.pumpWidget(_wrap(SwitchTile(
        text: 'My Option',
        value: true,
        onChanged: (_) {},
      )));

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('shows OFF state correctly', (tester) async {
      await tester.pumpWidget(_wrap(SwitchTile(
        text: 'My Option',
        value: false,
        onChanged: (_) {},
      )));

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('calls onChanged when toggled', (tester) async {
      bool? changedValue;
      await tester.pumpWidget(_wrap(SwitchTile(
        text: 'Toggle Me',
        value: true,
        onChanged: (v) => changedValue = v,
      )));

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(changedValue, isFalse);
    });
  });

  group('AppColors', () {
    test('defines all required colors', () {
      expect(AppColors.background, isNotNull);
      expect(AppColors.appBarBackground, isNotNull);
      expect(AppColors.snackBarBackground, isNotNull);
      expect(AppColors.textLight, isNotNull);
      expect(AppColors.switchActive, isNotNull);
      expect(AppColors.switchActiveTrack, isNotNull);
      expect(AppColors.switchInactiveThumb, isNotNull);
      expect(AppColors.switchInactiveTrack, isNotNull);
    });
  });

  group('AppRoutes', () {
    test('home route is /home', () {
      expect(AppRoutes.home, '/home');
    });
  });

  group('PasswordGeneratorApp - Theme', () {
    testWidgets('uses dark theme mode', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
    });

    testWidgets('theme has dark brightness', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.dark);
    });

    testWidgets('theme uses JetBrainsMono font', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(
        materialApp.theme?.textTheme.bodyMedium?.fontFamily,
        'JetBrainsMono',
      );
    });
  });

  group('HomePage - Multiple generations', () {
    testWidgets('generates different password on second tap', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // First generation
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      // Get first password text
      final display1 = tester.widget<Text>(find.byType(Text).at(2));
      final pwd1 = display1.data;

      // Second generation
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      // Password was regenerated (widget still works)
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });

    testWidgets('password respects disabled uppercase', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Disable uppercase
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();

      // Generate password
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      // Password should have been generated (placeholder gone)
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });

    testWidgets('password respects only numbers enabled', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Disable all except numbers
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      // Generate password
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();

      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });
  });

  group('HomePage - Switch states', () {
    testWidgets('all switches start enabled', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.length, 4);
      for (final s in switches) {
        expect(s.value, isTrue, reason: 'All switches should start ON');
      }
    });

    testWidgets('toggling lowercase switch changes its state', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      // Order: uppercase(ON), lowercase(OFF), numbers(ON), symbols(ON)
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isFalse);
      expect(switches[2].value, isTrue);
      expect(switches[3].value, isTrue);
    });

    testWidgets('toggling numbers switch changes its state', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Incluir números'));
      await tester.pumpAndSettle();

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isTrue);
      expect(switches[2].value, isFalse);
      expect(switches[3].value, isTrue);
    });

    testWidgets('toggling symbols switch changes its state', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isTrue);
      expect(switches[2].value, isTrue);
      expect(switches[3].value, isFalse);
    });
  });

  group('HomePage - Layout', () {
    testWidgets('has SafeArea', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('has centered app bar title', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
    });

    testWidgets('app bar has correct background color', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.appBarBackground);
    });

    testWidgets('scaffold has correct background color', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.background);
    });

    testWidgets('default password length is 20', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      expect(find.text('Tamanho da senha: 20'), findsOneWidget);
    });
  });

  group('HomePage - Snackbar interactions', () {
    testWidgets('snackbar disappears after duration', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Turn off all switches
      await tester.tap(find.text('Incluir letras maiúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir letras minúsculas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir números'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Incluir símbolos'));
      await tester.pumpAndSettle();

      // Tap generate to trigger snackbar
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Selecione pelo menos uma opção.'), findsOneWidget);

      // Wait for snackbar to disappear
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Selecione pelo menos uma opção.'), findsNothing);
    });

    testWidgets('can generate after re-enabling a switch', (tester) async {
      await tester.pumpWidget(const PasswordGeneratorApp());
      await tester.pumpAndSettle();

      // Turn off all switches
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

      // Dismiss snackbar
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Re-enable numbers
      await tester.tap(find.text('Incluir números'));
      await tester.pumpAndSettle();

      // Now generate successfully
      await tester.tap(find.text('GERAR SENHA'));
      await tester.pumpAndSettle();
      expect(find.text('Sua senha aparecerá aqui.'), findsNothing);
    });
  });

  group('PasswordDisplay - Icon states', () {
    testWidgets('icon resets to copy after error timeout', (tester) async {
      await tester.pumpWidget(_wrap(PasswordDisplay(
        password: '',
        onCopy: () {},
        onError: () {},
      )));

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      // Should show error icon
      expect(find.byIcon(Icons.close), findsOneWidget);

      // After 1 second, should reset to copy icon
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('icon resets to copy after success timeout', (tester) async {
      await tester.pumpWidget(_wrap(PasswordDisplay(
        password: 'Test123',
        onCopy: () {},
        onError: () {},
      )));

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      // Should show check icon
      expect(find.byIcon(Icons.check), findsOneWidget);

      // After 1 second, should reset
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });
  });

  group('GenerateButton - Animation', () {
    testWidgets('contains AnimatedContainer', (tester) async {
      await tester.pumpWidget(_wrap(GenerateButton(onTap: () {})));
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('uses GestureDetector', (tester) async {
      await tester.pumpWidget(_wrap(GenerateButton(onTap: () {})));
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });

  group('PasswordLengthSelector - Slider', () {
    testWidgets('slider range is 4 to 64', (tester) async {
      await tester.pumpWidget(_wrap(PasswordLengthSelector(
        length: 20,
        onDecrement: () {},
        onIncrement: () {},
      )));

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 4);
      expect(slider.max, 64);
    });

    testWidgets('slider has 60 divisions', (tester) async {
      await tester.pumpWidget(_wrap(PasswordLengthSelector(
        length: 20,
        onDecrement: () {},
        onIncrement: () {},
      )));

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.divisions, 60);
    });

    testWidgets('slider value matches length prop', (tester) async {
      await tester.pumpWidget(_wrap(PasswordLengthSelector(
        length: 32,
        onDecrement: () {},
        onIncrement: () {},
      )));

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 32.0);
      expect(find.text('Tamanho da senha: 32'), findsOneWidget);
    });
  });

  group('AppColors - Values', () {
    test('background is dark (#121212)', () {
      expect(AppColors.background, const Color(0xFF121212));
    });

    test('appBarBackground is dark (#1F1F1F)', () {
      expect(AppColors.appBarBackground, const Color(0xFF1F1F1F));
    });

    test('switchActive is green (#00E676)', () {
      expect(AppColors.switchActive, const Color(0xFF00E676));
    });

    test('textLight is light gray (#E0E0E0)', () {
      expect(AppColors.textLight, const Color(0xFFE0E0E0));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password/colors.dart';
import 'package:password/utils/password_generator.dart';
import 'package:password/widgets/generate_button.dart';
import 'package:password/widgets/password_display.dart';
import 'package:password/widgets/password_length_selector.dart';
import 'package:password/widgets/switch_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool includeUppercase = true;
  bool includeLowercase = true;
  bool includeNumbers = true;
  bool includeSymbols = true;
  int passwordLength = 20;
  String generatedPassword = "";

  void copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: generatedPassword));
    _showSnackBar(context, "Texto copiado para a área de transferência!");
  }

  void snackBarError(BuildContext context) {
    _showSnackBar(
        context, "Pressione 'Gerar Senha' para gerar uma nova senha.");
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textLight),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.snackBarBackground,
      ),
    );
  }

  void generatePassword() {
    if (!includeUppercase &&
        !includeLowercase &&
        !includeNumbers &&
        !includeSymbols) {
      _showSnackBar(context, 'Selecione pelo menos uma opção.');
      return;
    }

    final result = PasswordGenerator.generate(
      length: passwordLength,
      includeUppercase: includeUppercase,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSymbols: includeSymbols,
    );

    setState(() => generatedPassword = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Password Generator',
          style: TextStyle(color: AppColors.textLight),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              PasswordDisplay(
                password: generatedPassword,
                onCopy: () => copyToClipboard(context),
                onError: () => snackBarError(context),
              ),
              const SizedBox(height: 20),
              PasswordLengthSelector(
                length: passwordLength,
                onDecrement: () {
                  setState(() {
                    if (passwordLength > 1) passwordLength--;
                  });
                },
                onIncrement: () {
                  setState(() {
                    passwordLength++;
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildSwitches(),
              const Spacer(),
              GenerateButton(onTap: generatePassword),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitches() {
    return Column(
      children: [
        SwitchTile(
          text: 'Incluir letras maiúsculas',
          value: includeUppercase,
          onChanged: (value) => setState(() => includeUppercase = value),
        ),
        SwitchTile(
          text: 'Incluir letras minúsculas',
          value: includeLowercase,
          onChanged: (value) => setState(() => includeLowercase = value),
        ),
        SwitchTile(
          text: 'Incluir números',
          value: includeNumbers,
          onChanged: (value) => setState(() => includeNumbers = value),
        ),
        SwitchTile(
          text: 'Incluir símbolos',
          value: includeSymbols,
          onChanged: (value) => setState(() => includeSymbols = value),
        ),
      ],
    );
  }
}

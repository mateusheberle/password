import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password/colors.dart';

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
      setState(() {
        _showSnackBar(context, "Selecione pelo menos uma opção.");
      });
      return;
    }

    const String upperCaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const String lowerCaseLetters = "abcdefghijklmnopqrstuvwxyz";
    const String numbers = "0123456789";
    const String symbols = "!@#\$%^&*()-_=+[]{}|;:'\",.<>?/~";

    String chars = "";
    if (includeUppercase) chars += upperCaseLetters;
    if (includeLowercase) chars += lowerCaseLetters;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    final random = Random();
    generatedPassword = chars.isNotEmpty
        ? List.generate(
                passwordLength, (index) => chars[random.nextInt(chars.length)])
            .join()
        : "";

    setState(() {});
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
      body: Padding(
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
    );
  }

  Widget _buildSwitches() {
    return Column(
      children: [
        _SwitchTile(
          text: 'Incluir letras maiúsculas',
          value: includeUppercase,
          onChanged: (value) => setState(() => includeUppercase = value),
        ),
        _SwitchTile(
          text: 'Incluir letras minúsculas',
          value: includeLowercase,
          onChanged: (value) => setState(() => includeLowercase = value),
        ),
        _SwitchTile(
          text: 'Incluir números',
          value: includeNumbers,
          onChanged: (value) => setState(() => includeNumbers = value),
        ),
        _SwitchTile(
          text: 'Incluir símbolos',
          value: includeSymbols,
          onChanged: (value) => setState(() => includeSymbols = value),
        ),
      ],
    );
  }
}

class PasswordDisplay extends StatefulWidget {
  final String password;
  final VoidCallback onCopy;
  final VoidCallback onError;

  const PasswordDisplay({
    super.key,
    required this.password,
    required this.onCopy,
    required this.onError,
  });

  @override
  State<PasswordDisplay> createState() => _PasswordDisplayState();
}

class _PasswordDisplayState extends State<PasswordDisplay> {
  bool _copied = false;
  bool _error = false;

  Future<void> _copyToClipboard() async {
    setState(() {
      if (widget.password.isEmpty) {
        _error = true;
        widget.onError();
      } else {
        _copied = true;
        widget.onCopy();
      }
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _copied = false;
      _error = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.password.isEmpty
                  ? "Sua senha aparecerá aqui."
                  : widget.password,
              style: const TextStyle(fontSize: 20, color: AppColors.textLight),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              _error
                  ? Icons.close
                  : _copied
                      ? Icons.check
                      : Icons.copy,
              color: _error ? Colors.red : AppColors.switchActive,
            ),
            onPressed: _copyToClipboard,
          ),
        ],
      ),
    );
  }
}

class PasswordLengthSelector extends StatelessWidget {
  final int length;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const PasswordLengthSelector({
    super.key,
    required this.length,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    int passwordLength = length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Tamanho da senha: $passwordLength'),
        Slider(
          value: passwordLength.toDouble(),
          min: 4,
          max: 64,
          divisions: 60,
          label: passwordLength.toString(),
          activeColor: AppColors.switchActive,
          inactiveColor: AppColors.switchInactiveTrack,
          thumbColor: AppColors.switchActive,
          onChanged: (value) {
            if (value < passwordLength) {
              onDecrement();
            } else if (value > passwordLength) {
              onIncrement();
            }
          },
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(text, style: const TextStyle(color: AppColors.textLight)),
      activeColor: AppColors.switchActive,
      activeTrackColor: AppColors.switchActiveTrack,
      inactiveThumbColor: AppColors.switchInactiveThumb,
      inactiveTrackColor: AppColors.switchInactiveTrack,
    );
  }
}

class GenerateButton extends StatefulWidget {
  final VoidCallback onTap;

  const GenerateButton({super.key, required this.onTap});

  @override
  State<GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<GenerateButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.switchActive,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        child: const Center(
          child: Text(
            "GERAR SENHA",
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

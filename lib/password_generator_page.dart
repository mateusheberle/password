import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key});

  @override
  _PasswordGeneratorPageState createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  bool includeUppercase = true;
  bool includeLowercase = true;
  bool includeNumbers = true;
  bool includeSymbols = true;
  int passwordLength = 20;
  String generatedPassword = "";

  void copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: generatedPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Texto copiado para a área de transferência!")),
    );
  }

  void generatePassword() {
    if (includeLowercase == false &&
        includeUppercase == false &&
        includeNumbers == false &&
        includeSymbols == false) {
      return;
    }
    // Lógica para gerar a senha com base nos critérios
    const String upperCaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const String lowerCaseLetters = "abcdefghijklmnopqrstuvwxyz";
    const String numbers = "0123456789";
    const String symbols = "!@#\$%^&*()-_=+[]{}|;:'\",.<>?/~";

    String chars = "";
    if (includeUppercase) chars += upperCaseLetters;
    if (includeLowercase) chars += lowerCaseLetters;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    // generatedPassword = List.generate(
    //   passwordLength,
    //   (index) => chars[(chars.length * index ~/ passwordLength) % chars.length],
    // ).join();

    final random = Random();
    if (chars.isEmpty) {
      generatedPassword = "";
    } else {
      generatedPassword = List.generate(
        passwordLength,
        (index) => chars[random.nextInt(chars.length)],
      ).join();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[900],
      appBar: AppBar(
        title: const Text(
          'Password Generator',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          generatedPassword.isEmpty
                              ? "Your password will appear here"
                              : generatedPassword,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        onPressed: () => copyToClipboard(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Password length:',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              if (passwordLength > 1) passwordLength--;
                            });
                          },
                        ),
                        Expanded(
                          child: Container(
                            height: 50,
                            color: Colors.green[700],
                            child: Center(
                              child: Text(passwordLength.toString(),
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              passwordLength++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _switch('Include uppercase letters', includeUppercase, 0),
            _switch('Include lowercase letters', includeLowercase, 1),
            _switch('Include numbers', includeNumbers, 2),
            _switch('Include symbols', includeSymbols, 3),
            const Spacer(),
            SizedBox(
              height: 68,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Material(
                  child: InkWell(
                    onTap: generatePassword,
                    child: Container(
                      color: Colors.green[700],
                      child: const Center(
                        child: Text(
                          'GENERATE',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SwitchListTile _switch(String text, bool booleano, int index) {
    return SwitchListTile(
      value: booleano,
      onChanged: (value) {
        setState(() {
          if (index == 0) includeUppercase = value;
          if (index == 1) includeLowercase = value;
          if (index == 2) includeNumbers = value;
          if (index == 3) includeSymbols = value;
        });
      },
      title: Text(text, style: const TextStyle(color: Colors.white)),
      activeColor: Colors.green, // Cor do thumb quando o switch está ativo
      activeTrackColor:
          Colors.green[200], // Cor da track quando o switch está ativo
      inactiveThumbColor:
          Colors.red, // Cor do thumb quando o switch está inativo
      inactiveTrackColor:
          Colors.red[200], // Cor da track quando o switch está inativo
    );
  }
}

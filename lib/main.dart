import 'package:flutter/material.dart';

import 'password_generator_page.dart';
import 'splash_screen.dart';

void main() {
  runApp(const PasswordGeneratorApp());
}

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[900],
        scaffoldBackgroundColor: Colors.green[900],
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) =>
            const PasswordGeneratorPage(), // Sua tela principal
      },
    );
  }
}

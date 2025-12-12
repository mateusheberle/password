import 'package:flutter/material.dart';
import 'package:password/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PasswordGeneratorApp());
}

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  static const String title = 'Password Generator';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'JetBrainsMono',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'JetBrainsMono',
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomePage(),
      },
    );
  }
}

/// Constantes de rotas da aplicação.
class AppRoutes {
  AppRoutes._();
  static const String home = '/home';
}

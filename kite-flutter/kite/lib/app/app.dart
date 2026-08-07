import 'package:flutter/material.dart';
import 'package:kite/app/app_theme.dart';
import 'package:kite/features/auth/presentation/screens/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginPage(),
    );
  }
}

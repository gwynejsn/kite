import 'package:flutter/material.dart';
import 'package:kite/app/app_theme.dart';
import 'package:kite/features/auth/presentation/screens/login_page.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<UserProfileProvider>().themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const LoginPage(),
    );
  }
}

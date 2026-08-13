import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kite/app/app.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/networks/jwt_service.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProfileProvider(
            sl<http.Client>(),
            sl<JwtService>(),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}

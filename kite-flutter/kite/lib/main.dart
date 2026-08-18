import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kite/app/app.dart';
import 'package:kite/features/presence/presentation/presence_provider.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/networks/websocket_service.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProfileProvider(sl<Dio>()),
        ),
        ChangeNotifierProvider.value(value: sl<WebsocketService>()),
        ChangeNotifierProvider.value(value: sl<PresenceProvider>()),
      ],
      child: const App(),
    ),
  );
}

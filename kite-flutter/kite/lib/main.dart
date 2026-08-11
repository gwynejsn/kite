import 'package:flutter/material.dart';
import 'package:kite/app/app.dart';
import 'package:kite/core/di/injection_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();
  runApp(const App());
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/dependency_injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DI().initialize();
  runApp(const App());
  unawaited(
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  );
}

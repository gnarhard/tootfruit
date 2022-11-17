import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Locator.registerAll();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const App());
  });
}

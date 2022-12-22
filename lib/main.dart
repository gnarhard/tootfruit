import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Locator.registerAll();
  MobileAds.instance.initialize();
  final RequestConfiguration requestConfiguration =
      RequestConfiguration(tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes);
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const App());
  });
}

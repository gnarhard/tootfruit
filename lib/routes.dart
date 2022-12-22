import 'package:flutter/cupertino.dart';
import 'package:tootfruit/screens/launch_screen.dart';
import 'package:tootfruit/screens/toot_fairy_screen.dart';
import 'package:tootfruit/screens/toot_loot_screen.dart';
import 'package:tootfruit/screens/toot_screen.dart';

final routes = <String, Widget Function(BuildContext)>{
  LaunchScreen.route: (context) => const LaunchScreen(), // /launch
  TootScreen.route: (context) => const TootScreen(), // /toot
  TootFairyScreen.route: (context) => const TootFairyScreen(), // /toot_fairy
  TootLootScreen.route: (context) => const TootLootScreen(), // /toot_loot
};

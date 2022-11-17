import 'package:flutter/cupertino.dart';
import 'package:tooty_fruity/screens/launch_screen.dart';
import 'package:tooty_fruity/screens/toot_screen.dart';

final routes = <String, Widget Function(BuildContext)>{
  LaunchScreen.route: (context) => const LaunchScreen(), // /launch
  TootScreen.route: (context) => const TootScreen(), // /fart
};

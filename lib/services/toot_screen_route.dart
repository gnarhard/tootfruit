import 'package:flutter/material.dart';
import 'package:tootfruit/screens/toot_screen.dart';

const Duration _initialTootScreenFadeDuration = Duration(milliseconds: 240);

Route<void> buildInitialTootScreenRoute({String routeName = TootScreen.route}) {
  return PageRouteBuilder<void>(
    settings: RouteSettings(name: routeName),
    transitionDuration: _initialTootScreenFadeDuration,
    reverseTransitionDuration: _initialTootScreenFadeDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return const TootScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

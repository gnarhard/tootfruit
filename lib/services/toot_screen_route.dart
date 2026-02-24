import 'package:flutter/material.dart';
import 'package:tootfruit/screens/toot_screen.dart';

const Duration _initialTootScreenFadeDuration = Duration(milliseconds: 240);

Route<void> buildInitialTootScreenRoute() {
  return PageRouteBuilder<void>(
    settings: const RouteSettings(name: TootScreen.route),
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

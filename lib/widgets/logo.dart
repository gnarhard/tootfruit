import 'package:flutter/material.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/models/toot.dart';
import 'package:tooty_fruity/screens/toot_screen.dart';
import 'package:tooty_fruity/services/toot_service.dart';

class AppLogo extends StatelessWidget {
  AppLogo({Key? key}) : super(key: key);

  final _tootService = Locator.get<TootService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Toot>(
        stream: _tootService.current$,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          final toot = snapshot.requireData;
          return Text(
            toot.emoji,
            style: const TextStyle(fontSize: TootScreen.startingFontSize, height: 2),
          );
        });
  }
}

import 'package:flutter/material.dart';
import 'package:tootfruit/screens/toot_fairy_screen.dart';
import 'package:tootfruit/services/init_service.dart';

import '../locator.dart';

class LaunchScreen extends StatefulWidget {
  static const route = '/launch';

  const LaunchScreen({Key? key}) : super(key: key);

  @override
  LaunchScreenState createState() => LaunchScreenState();
}

class LaunchScreenState extends State<LaunchScreen> {
  late final _initService = Locator.get<InitService>();

  static const _firstColor = Colors.pink;

  @override
  void initState() {
    super.initState();
    _initService.init();
  }

  @override
  Widget build(BuildContext context) {
    TootFairyScreen.precacheImages(context);

    return Container(
      color: _firstColor,
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                color: Colors.white54,
              ),
            ),
          )
        ]),
      ),
    );
  }
}

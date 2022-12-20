import 'package:flutter/material.dart';
import 'package:toot_fruit/services/init_service.dart';

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
  Widget build(BuildContext context) {
    _initService.init(context);

    return Container(
      color: _firstColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
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

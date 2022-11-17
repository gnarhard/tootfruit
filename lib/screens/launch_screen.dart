import 'package:flutter/material.dart';
import 'package:tooty_fruity/services/init_service.dart';

import '../locator.dart';

class LaunchScreen extends StatefulWidget {
  static const route = '/launch';

  const LaunchScreen({Key? key}) : super(key: key);

  @override
  LaunchScreenState createState() => LaunchScreenState();
}

class LaunchScreenState extends State<LaunchScreen> {
  late final _initService = Locator.get<InitService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
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

  @override
  void initState() {
    super.initState();
    _initService.init();
  }
}

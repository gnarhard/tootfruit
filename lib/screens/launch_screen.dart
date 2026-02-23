import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tootfruit/screens/toot_fairy_screen.dart';
import 'package:tootfruit/services/init_service.dart';

import '../locator.dart';

class LaunchScreen extends StatefulWidget {
  static const route = '/launch';

  const LaunchScreen({super.key});

  @override
  LaunchScreenState createState() => LaunchScreenState();
}

class LaunchScreenState extends State<LaunchScreen> {
  late final _initService = Locator.get<InitService>();

  static const _firstColor = Colors.pink;
  bool _didPrecacheImages = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initService.init());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheImages) {
      return;
    }

    _didPrecacheImages = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(TootFairyScreen.precacheImages(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _firstColor,
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

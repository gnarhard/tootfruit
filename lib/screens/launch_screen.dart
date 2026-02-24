import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tootfruit/services/init_service.dart';
import 'package:tootfruit/services/image_precache_service.dart';

import '../locator.dart';

class LaunchScreen extends StatefulWidget {
  static const route = '/launch';

  const LaunchScreen({super.key});

  @override
  LaunchScreenState createState() => LaunchScreenState();
}

class LaunchScreenState extends State<LaunchScreen> {
  late final _initService = Locator.get<InitService>();
  late final _imagePrecacheService = Locator.get<ImagePrecacheService>();

  static const _firstColor = Colors.pink;
  bool _didStartBootstrap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didStartBootstrap) {
      return;
    }

    _didStartBootstrap = true;
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      await _imagePrecacheService.precacheLaunchImages(context);
    } catch (error, stackTrace) {
      debugPrint('LaunchScreen: Failed to precache launch images: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (!mounted) {
      return;
    }
    await _initService.init();
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/services/fruit_query_param.dart';
import 'package:tootfruit/services/init_service.dart';

class LaunchScreen extends StatefulWidget {
  static const route = '/launch';

  const LaunchScreen({super.key});

  @override
  LaunchScreenState createState() => LaunchScreenState();
}

class LaunchScreenState extends State<LaunchScreen> {
  final _di = DI();
  late final Color _backgroundColor = resolveLaunchBackgroundColor(Uri.base);
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
      await _di.imagePrecacheService.precacheLaunchImages(context);
    } catch (error, stackTrace) {
      debugPrint('LaunchScreen: Failed to precache launch images: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (!mounted) {
      return;
    }
    await InitService().init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
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

Color resolveLaunchBackgroundColor(Uri uri) {
  final requestedFruit = readFruitQueryParamFromUri(uri);
  if (requestedFruit == null) {
    return toots.first.color;
  }

  final normalizedRequestedFruit = requestedFruit.toLowerCase();
  for (final toot in toots) {
    if (toot.fruit.toLowerCase() == normalizedRequestedFruit) {
      return toot.color;
    }
  }

  return toots.first.color;
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/toot_service.dart';

import '../screens/toot_screen.dart';
import '../services/toast_service.dart';

class TootFairy extends StatefulWidget {
  const TootFairy({Key? key}) : super(key: key);

  static const double fairyRotationSecondsSpeed = 2;

  @override
  State<TootFairy> createState() => _TootFairyState();
}

class _TootFairyState extends State<TootFairy> with TickerProviderStateMixin {
  late final _audioService = Locator.get<AudioService>();
  late final _tootService = Locator.get<TootService>();
  late final _navService = Locator.get<NavigationService>();

  late AnimationController _fairyAnimationController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _fairyAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0,
      upperBound: 24,
    );
    _fairyAnimationController.addListener(() {
      setState(() {});
    });

    _fairyAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fairyAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => {
        _timer = Timer(const Duration(seconds: 3), () async {
          await _audioService.stop();
          await _tootService.rewardAll();
          _navService.current.pushNamed(TootScreen.route);
          ToastService.success(message: "Whoa! You know the secret!");
        })
      },
      onPanEnd: (details) => _timer!.cancel(),
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          margin: EdgeInsets.only(top: _fairyAnimationController.value),
          child: Image.asset(
            'assets/images/toot_fairy.png',
            width: constraints.maxWidth / 3,
          ),
        );
      }),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tootfruit/core/dependency_injection.dart';

import '../screens/toot_screen.dart';

class TootFairy extends StatefulWidget {
  const TootFairy({super.key});

  static const double fairyRotationSecondsSpeed = 2;

  @override
  State<TootFairy> createState() => _TootFairyState();
}

class _TootFairyState extends State<TootFairy> with TickerProviderStateMixin {
  final _di = DI();

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  static const _quick = Duration(milliseconds: 200);
  static const _quicker = Duration(milliseconds: 80);
  double _scale = 0.8;
  double _angle = 0.0;
  late AnimationController _fairyAnimationController;
  Timer? _timer;
  bool _audioLoaded = false;
  Duration? _audioDuration;

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

    final scaleTween = Tween(begin: _scale, end: 1.0);
    final rotateTween = Tween(begin: _angle, end: .5);
    _scaleController = AnimationController(duration: _quick, vsync: this);
    _rotationController = AnimationController(duration: _quicker, vsync: this);

    _scaleAnimation =
        scaleTween.animate(
          CurvedAnimation(
            parent: _scaleController,
            curve: Curves.linearToEaseOut,
          ),
        )..addListener(() {
          setState(() => _scale = _scaleAnimation.value);
        });

    _rotationAnimation =
        rotateTween.animate(
          CurvedAnimation(parent: _rotationController, curve: Curves.linear),
        )..addListener(() {
          setState(() => _angle = _rotationAnimation.value);
        });
  }

  @override
  void dispose() {
    _cancelSecretTimer();
    _fairyAnimationController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _angle,
      child: Transform.scale(
        scale: _scale,
        child: GestureDetector(
          onTap: () => _tootAndAnimate(),
          onPanDown: (_) {
            _cancelSecretTimer();
            _timer = Timer(const Duration(seconds: 3), () async {
              if (!mounted) {
                return;
              }
              await _di.audioPlayer.stop();
              _di.navigationService.current.pushNamed(TootScreen.route);
            });
          },
          onPanCancel: _cancelSecretTimer,
          onPanEnd: (details) => _cancelSecretTimer(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                margin: EdgeInsets.only(top: _fairyAnimationController.value),
                child: Image.asset(
                  'assets/images/toot_fairy.png',
                  width: constraints.maxWidth / 3,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _animate() {
    _rotationController
        .repeat(reverse: true)
        .timeout(
          _audioDuration!,
          onTimeout: () {
            _rotationController
                .reverse(from: .5)
                .whenComplete(() => _rotationController.stop());
          },
        );

    _scaleController.forward().whenComplete(() => _scaleController.reverse());
  }

  void _tootAndAnimate() async {
    _cancelSecretTimer();

    if (!_audioLoaded) {
      _audioDuration = await _di.audioPlayer.setAudio(
        'asset:///assets/audio/toot_fairy.mp3',
      );
      _audioLoaded = true;
    }

    _di.audioPlayer.play();
    _animate();
  }

  void _cancelSecretTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

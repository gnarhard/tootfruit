import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tooty_fruity/drawer.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/services/audio_service.dart';
import 'package:tooty_fruity/services/toot_service.dart';
import 'package:tooty_fruity/widgets/logo.dart';

import '../models/toot.dart';

class TootScreen extends StatefulWidget {
  static const String route = '/fart';
  const TootScreen({Key? key}) : super(key: key);
  static const double startingFontSize = 130;

  @override
  TootScreenState createState() => TootScreenState();
}

class TootScreenState extends State<TootScreen> with SingleTickerProviderStateMixin {
  final _audioService = Locator.get<AudioService>();
  final _tootService = Locator.get<TootService>();

  late Animation<double> _animation;
  late AnimationController _controller;
  static const _quick = Duration(milliseconds: 200);
  double _scale = 0.7;
  final int _shakeCount = 3;

  @override
  void initState() {
    super.initState();
    final scaleTween = Tween(begin: _scale, end: 1.0);
    _controller = AnimationController(duration: _quick, vsync: this);
    _animation = scaleTween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastLinearToSlowEaseIn,
        // curve: SineCurve(count: _shakeCount.toDouble()),
      ),
    )..addListener(() {
        setState(() => _scale = _animation.value);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.removeStatusListener((listener) => {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Toot>(
        stream: _tootService.current$,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final toot = snapshot.requireData;

          return Scaffold(
            backgroundColor: toot.color,
            drawer: const AppDrawer(),
            appBar: AppBar(
              leading: Container(),
              centerTitle: true,
              elevation: 0,
              title: Text(
                toot.title.toUpperCase(),
                style: TextStyle(color: Colors.white.withAlpha(100)),
              ),
              backgroundColor: toot.color,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: _scale,
                  child: GestureDetector(
                    onTap: () async {
                      _controller.forward().whenComplete(
                          () => _controller.reverse().then((value) => _tootService.shuffle()));
                      await _audioService.play();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: TootScreen.startingFontSize / 2),
                      child: SizedBox(width: MediaQuery.of(context).size.width, child: AppLogo()),
                    ),
                  ),
                ),
                const Text('tap that', style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          );
        });
  }
}

class SineCurve extends Curve {
  const SineCurve({this.count = 3});
  final double count;

  // 2. override transformInternal() method
  @override
  double transformInternal(double t) {
    return sin(count * 2 * pi * t);
  }
}

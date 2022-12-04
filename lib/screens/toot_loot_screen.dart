import 'package:flutter/material.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/screens/toot_screen.dart';
import 'package:tooty_fruity/services/audio_service.dart';
import 'package:tooty_fruity/services/navigation_service.dart';
import 'package:tooty_fruity/services/toot_service.dart';

import '../models/toot.dart';

class TootLootScreen extends StatefulWidget {
  static const String route = '/toot_loot';

  const TootLootScreen({Key? key}) : super(key: key);

  @override
  State<TootLootScreen> createState() => _TootLootScreenState();
}

class _TootLootScreenState extends State<TootLootScreen> with TickerProviderStateMixin {
  late final _tootService = Locator.get<TootService>();
  late final _audioService = Locator.get<AudioService>();
  late final _navService = Locator.get<NavigationService>();

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  static const _quick = Duration(milliseconds: 200);
  static const _quicker = Duration(milliseconds: 80);
  double _scale = 0.7;
  double _angle = 0.0;

  @override
  void initState() {
    super.initState();

    final scaleTween = Tween(begin: _scale, end: 1.0);
    final rotateTween = Tween(begin: _angle, end: .5);
    _scaleController = AnimationController(duration: _quick, vsync: this);
    _rotationController = AnimationController(duration: _quicker, vsync: this);

    _scaleAnimation = scaleTween.animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.linearToEaseOut,
      ),
    )..addListener(() {
        setState(() => _scale = _scaleAnimation.value);
      });

    _rotationAnimation = rotateTween.animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    )..addListener(() {
        setState(() => _angle = _rotationAnimation.value);
      });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _scaleController.removeStatusListener((listener) => {});
    _rotationController.dispose();
    _rotationController.removeStatusListener((listener) => {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: StreamBuilder<Toot>(
          stream: _tootService.newLoot$,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final toot = snapshot.requireData;
            _animate(toot);

            return Scaffold(
              backgroundColor: toot.color,
              appBar: AppBar(
                leading: Container(),
                centerTitle: true,
                elevation: 0,
                title: Text(
                  'TOOT LOOT: ${toot.title.toUpperCase()}',
                  style: TextStyle(
                      color: toot.darkText
                          ? Colors.grey.withOpacity(.8)
                          : Colors.white.withOpacity(.6)),
                ),
                backgroundColor: toot.color,
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Stack(
                    children: [
                      const Image(image: AssetImage('images/explosion.png')),
                      Transform.rotate(
                        angle: _angle,
                        child: Transform.scale(
                          scale: _scale,
                          child: SizedBox(
                            width: TootScreen.startingFontSize,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                toot.emoji,
                                style: const TextStyle(
                                    fontSize: TootScreen.startingFontSize, height: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('start tooting',
                        style: TextStyle(
                            color: toot.darkText ? Colors.black.withOpacity(.8) : Colors.white,
                            fontSize: 20)),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                        onPressed: () {
                          _navService.current.pushNamed(TootScreen.route);
                        },
                        child: Text('VISIT THE TOOT FAIRY',
                            style: TextStyle(
                                color: toot.darkText
                                    ? Colors.grey.withOpacity(.8)
                                    : Colors.white.withOpacity(.7)))),
                  ),
                ],
              ),
            );
          }),
    );
  }

  void _resetAnimations() {
    setState(() {
      _scaleController.stop();
      _rotationController.stop();
      _scale = .7;
      _angle = 0;
    });
  }

  void _animate(Toot toot) {
    _rotationController.repeat(reverse: true);
    _scaleController.repeat(reverse: true);
  }
}

import 'package:flutter/material.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/screens/toot_fairy_screen.dart';
import 'package:tooty_fruity/services/audio_service.dart';
import 'package:tooty_fruity/services/navigation_service.dart';
import 'package:tooty_fruity/services/toot_service.dart';

import '../models/toot.dart';

class TootScreen extends StatefulWidget {
  static const String route = '/toot';

  const TootScreen({Key? key}) : super(key: key);
  static const double startingFontSize = 130;

  @override
  TootScreenState createState() => TootScreenState();
}

class TootScreenState extends State<TootScreen> with TickerProviderStateMixin {
  final _audioService = Locator.get<AudioService>();
  final _tootService = Locator.get<TootService>();
  late final _navService = Locator.get<NavigationService>();

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _opacityController;
  static const _quick = Duration(milliseconds: 200);
  static const _quicker = Duration(milliseconds: 80);
  static const _long = Duration(milliseconds: 3000);
  double _scale = 0.7;
  double _angle = 0.0;
  static const double swipeSensitivity = 800;

  Color _textColor(Toot toot) => toot.darkText ? toot.color.darken(30) : toot.color.lighten(30);
  Color _contrastTextColor(Toot toot) =>
      toot.darkText ? toot.color.darken(50) : toot.color.lighten(50);

  @override
  void initState() {
    super.initState();

    final scaleTween = Tween(begin: _scale, end: 1.0);
    final rotateTween = Tween(begin: _angle, end: .5);
    _scaleController = AnimationController(duration: _quick, vsync: this);
    _rotationController = AnimationController(duration: _quicker, vsync: this);
    _opacityController = AnimationController(duration: _long, vsync: this)..repeat(reverse: true);

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

    _opacityAnimation = CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _scaleController.removeStatusListener((listener) => {});
    _rotationController.dispose();
    _rotationController.removeStatusListener((listener) => {});
    _opacityController.dispose();
    _opacityController.removeStatusListener((listener) => {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onHorizontalDragEnd: (details) async {
          // Note: Sensitivity is integer used when you don't want to mess up vertical drag
          if (details.velocity.pixelsPerSecond.dx < -swipeSensitivity) {
            // Swiped right.
            _resetAnimations();
            await _tootService.increment();
          } else if (details.velocity.pixelsPerSecond.dx > swipeSensitivity) {
            // Swiped left.
            _resetAnimations();
            await _tootService.decrement();
          }
        },
        child: StreamBuilder<Toot>(
            stream: _tootService.current$,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final toot = snapshot.requireData;

              return Scaffold(
                backgroundColor: toot.color,
                appBar: AppBar(
                  leading: Container(),
                  centerTitle: true,
                  elevation: 0,
                  title: Text(
                    toot.title.toUpperCase(),
                    style: TextStyle(color: _textColor(toot)),
                  ),
                  backgroundColor: toot.color,
                ),
                body: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Transform.rotate(
                        angle: _angle,
                        child: Transform.scale(
                          scale: _scale,
                          child: GestureDetector(
                            onTap: () async {
                              _animate(toot);
                              await _audioService.play();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                /// Gives container an actual size
                                color: Colors.transparent,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: TootScreen.startingFontSize + 16),
                                child: Text(
                                  toot.emoji,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      // backgroundColor: Colors.red,
                                      fontSize: TootScreen.startingFontSize,
                                      height: 2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('tap that',
                            style: TextStyle(color: _contrastTextColor(toot), fontSize: 20)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                        child: FadeTransition(
                          opacity: _opacityAnimation,
                          child: _tootService.owned$.value.length == 1
                              ? const SizedBox(height: 100)
                              : Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/swipe.png',
                                      height: 100,
                                      width: 100,
                                      color: _textColor(toot),
                                      colorBlendMode: BlendMode.srcATop,
                                      fit: BoxFit.fitWidth,
                                    ),
                                    Text('swipe', style: TextStyle(color: _textColor(toot))),
                                  ],
                                ),
                        ),
                      ),
                      _tootService.ownsEveryToot
                          ? const SizedBox(height: 64)
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextButton(
                                  onPressed: () {
                                    _navService.current.pushNamed(TootFairyScreen.route);
                                  },
                                  child: Text('VISIT THE TOOT FAIRY',
                                      style: TextStyle(color: _textColor(toot)))),
                            ),
                    ],
                  ),
                ),
              );
            }),
      ),
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
    _rotationController.repeat(reverse: true).timeout(toot.duration!, onTimeout: () {
      _rotationController.reverse(from: .5).whenComplete(() => _rotationController.stop());
    });

    _scaleController.forward().whenComplete(() => _scaleController.reverse());
  }
}

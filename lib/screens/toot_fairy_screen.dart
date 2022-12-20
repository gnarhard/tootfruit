import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toot_fruit/locator.dart';
import 'package:toot_fruit/screens/toot_loot_screen.dart';
import 'package:toot_fruit/screens/toot_screen.dart';
import 'package:toot_fruit/services/audio_service.dart';
import 'package:toot_fruit/services/navigation_service.dart';
import 'package:toot_fruit/services/toot_service.dart';

class TootFairyScreen extends StatefulWidget {
  static const String route = '/toot_fairy';

  const TootFairyScreen({Key? key}) : super(key: key);

  static Future<void> precacheImages(context) async {
    await precacheImage(const AssetImage('assets/images/all_fruits.png'), context);
    await precacheImage(const AssetImage('assets/images/clouds_bottom.png'), context);
    await precacheImage(const AssetImage('assets/images/clouds_top.png'), context);
    await precacheImage(const AssetImage('assets/images/cloud_simple.png'), context);
  }

  @override
  State<TootFairyScreen> createState() => _TootFairyScreenState();
}

class _TootFairyScreenState extends State<TootFairyScreen> with TickerProviderStateMixin {
  final _audioService = Locator.get<AudioService>();
  late final _navService = Locator.get<NavigationService>();
  late final _tootService = Locator.get<TootService>();

  static const Color _backgroundColor = Color(0xff53BAF3);
  static const Color _backgroundColorSecondary = Color(0xff43b6f6);
  // static const Color _buttonColor = Color(0xffFCE832);
  static const Color _buttonColor = _backgroundColor;

  static const _fruitRotationSpeed = Duration(seconds: 10);
  static const _fairyRotationDuration = Duration(seconds: 10);
  static const double _fairyRotationSpeed = 2;

  late final AnimationController _fruitRotationController =
      AnimationController(duration: _fruitRotationSpeed, vsync: this)..repeat();

  late AnimationController _fairyAnimationController;

  late final AnimationController _rotationController =
      AnimationController(duration: _fairyRotationDuration, vsync: this)..repeat(reverse: true);

  double _verticalOffset = -20;

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
    _startAudio();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fruitRotationController.dispose();
    super.dispose();
  }

  void changePosition(Timer t) async {
    setState(() {
      _verticalOffset = _verticalOffset == 0 ? 20 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(-0.4, -0.8),
              stops: [0, .5, .5, 1],
              tileMode: TileMode.repeated,
              colors: <Color>[
                _backgroundColor,
                _backgroundColor,
                _backgroundColorSecondary,
                _backgroundColorSecondary,
              ]),
        ),
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/clouds_top.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/clouds_bottom.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                iconTheme: const IconThemeData(
                  color: _backgroundColor, //change your color here
                ),
                backgroundColor: Colors.transparent,
                centerTitle: true,
                elevation: 0,
                title: Text(
                  'TOOT FAIRY'.toUpperCase(),
                  style: TextStyle(
                    color: _backgroundColorSecondary.withOpacity(.6),
                    fontSize: 32,
                    shadows: const <Shadow>[
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2.0,
                        color: Color.fromARGB(50, 0, 0, 255),
                      ),
                    ],
                  ),
                ),
              ),
              body: Stack(children: [
                Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.top +
                          MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(children: [
                        AnimatedBuilder(
                          animation: _fruitRotationController,
                          child: Image.asset(
                            'assets/images/all_fruits.png',
                            width: MediaQuery.of(context).size.width,
                          ),
                          builder: (BuildContext context, Widget? child) {
                            return Transform.rotate(
                              angle: _fruitRotationController.value * _fairyRotationSpeed * math.pi,
                              child: child,
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 80.0),
                          child: Image.asset(
                            'assets/images/cloud_simple.png',
                          ),
                        ),
                        GestureDetector(
                          onLongPress: () async {
                            _audioService.stop();
                            _tootService.rewardAll();
                            _navService.current.pushNamed(TootScreen.route);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Center(
                              child: Container(
                                margin: EdgeInsets.only(top: _fairyAnimationController.value),
                                child: SvgPicture.asset(
                                  'assets/images/toot_fairy.svg',
                                  width: 160,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              await _tootService.reward();
                              await _audioService.stop();
                              _navService.current.pushNamed(TootLootScreen.route);
                            },
                            style: ElevatedButton.styleFrom(
                                shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  width: 2,
                                  color: Colors.white,
                                ),
                                elevation: 10,
                                backgroundColor: _buttonColor,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                textStyle:
                                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            child: const Text("GIMME LOOT", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ]),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('watch an ad to get toot loot',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _backgroundColorSecondary.withOpacity(.7),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child:
                            Text('${_tootService.owned.length} / ${_tootService.all.length} owned',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _backgroundColorSecondary.withOpacity(.7),
                                )),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ));
  }

  Future<void> _startAudio() async {
    await _audioService.setAudio('asset:///assets/audio/toot_fairy.m4a');
    await _audioService.play();
  }
}

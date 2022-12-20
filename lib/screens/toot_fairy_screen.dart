import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/screens/toot_loot_screen.dart';
import 'package:tooty_fruity/screens/toot_screen.dart';
import 'package:tooty_fruity/services/audio_service.dart';
import 'package:tooty_fruity/services/navigation_service.dart';
import 'package:tooty_fruity/services/toot_service.dart';

class TootFairyScreen extends StatefulWidget {
  static const String route = '/toot_fairy';

  const TootFairyScreen({Key? key}) : super(key: key);

  @override
  State<TootFairyScreen> createState() => _TootFairyScreenState();
}

class _TootFairyScreenState extends State<TootFairyScreen> with TickerProviderStateMixin {
  final _audioService = Locator.get<AudioService>();
  late final _navService = Locator.get<NavigationService>();
  late final _tootService = Locator.get<TootService>();

  static const Color _buttonColor = Color(0xff1BDE22);
  static const Color _backgroundColor = Color(0xff182f1a);
  static const Color _backgroundColorSecondary = Color(0xff023a04);

  static const _fruitRotationSpeed = Duration(seconds: 10);
  static const _fairyRotationSpeed = Duration(milliseconds: 500);

  double _angle = -.2;

  late AnimationController _fruitRotationController;
  // late AnimationController _fairyAnimationController;

  late Animation<double> _rotationAnimation;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _fruitRotationController = AnimationController(duration: _fruitRotationSpeed, vsync: this)
      ..repeat(reverse: false);
    _rotationController = AnimationController(duration: _fairyRotationSpeed, vsync: this)
      ..repeat(reverse: true);

    final rotateTween = Tween(begin: _angle, end: .01);
    _rotationAnimation = rotateTween.animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    )..addListener(() {
        setState(() => _angle = _rotationController.value);
      });
    _startAudio();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fruitRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: const AssetImage('assets/images/colorful_explosion.jpg'),
      //     colorFilter: ColorFilter.mode(_backgroundColor.withOpacity(.5), BlendMode.multiply),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  _backgroundColor.withOpacity(1),
                  _backgroundColorSecondary.withOpacity(1)
                ]),
          ),
          child: Container(
            // decoration: BoxDecoration(
            //   image: DecorationImage(
            //     image: const AssetImage('assets/images/fairy_dust_inverted.png'),
            //     colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
            //     fit: BoxFit.cover,
            //   ),
            // ),
            child: Container(
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //     image: const AssetImage('assets/images/fairy_dust.png'),
              //     colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.05), BlendMode.dstATop),
              //     fit: BoxFit.cover,
              //   ),
              // ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  elevation: 0,
                  title: Text(
                    'Unlock Toot Loot!'.toUpperCase(),
                    style: TextStyle(color: Colors.white.withAlpha(80)),
                  ),
                ),
                body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Spacer(),
                  Stack(children: [
                    RotationTransition(
                        turns: Tween(begin: 1.0, end: 0.0).animate(_fruitRotationController),
                        child: Image.asset(
                          'assets/images/all_fruits.png',
                          width: double.maxFinite,
                        )),
                    GestureDetector(
                      onLongPress: () async {
                        _audioService.stop();
                        _tootService.rewardAll();
                        _navService.current.pushNamed(TootScreen.route);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80.0),
                        child: Center(
                          child: Transform.rotate(
                            angle: _angle,
                            child: SvgPicture.asset(
                              'assets/images/toot_fairy.svg',
                              width: 160,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Watch an ad to be rewarded with toot loot!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(.6))),
                  ),
                  const SizedBox(height: 32),
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
                            backgroundColor: _buttonColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        child: const Text("CLAIM", style: TextStyle(color: _backgroundColor)),
                      ),
                    ),
                  ]),
                  const Spacer(),
                ]),
              ),
            ),
          )),
    );
  }

  Future<void> _startAudio() async {
    await _audioService.setAudio('asset:///assets/audio/toot_fairy.m4a');
    await _audioService.play();
  }
}

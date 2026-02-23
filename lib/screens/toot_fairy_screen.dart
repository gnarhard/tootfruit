import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/widgets/cloud.dart';
import 'package:tootfruit/widgets/rotating_fruit.dart';
import 'package:tootfruit/widgets/toot_fairy.dart';

import '../widgets/screen_title.dart';

class TootFairyScreen extends StatefulWidget {
  static const String route = '/toot_fairy';

  const TootFairyScreen({super.key});

  static Future<void> precacheImages(BuildContext context) async {
    await Future.wait([
      precacheImage(const AssetImage('assets/images/all_fruits.png'), context),
      precacheImage(
        const AssetImage('assets/images/clouds_bottom_smaller.png'),
        context,
      ),
      precacheImage(
        const AssetImage('assets/images/clouds_top_smaller.png'),
        context,
      ),
      precacheImage(
        const AssetImage('assets/images/cloud_simple.png'),
        context,
      ),
    ]);
  }

  @override
  State<TootFairyScreen> createState() => _TootFairyScreenState();
}

class _TootFairyScreenState extends State<TootFairyScreen> {
  final _audioService = Locator.get<AudioService>();

  static const Color _backgroundColor = Color(0xff53BAF3);
  static const Color _backgroundColorSecondary = Color(0xff43b6f6);
  bool _hasStartedAudio = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_startAudio());
      }
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
          ],
        ),
      ),
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/clouds_top_smaller.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/clouds_bottom_smaller.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            key: const Key('tootFairyScreen'),
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: _backgroundColor),
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              actions: [
                IconButton(
                  key: const Key('tootFairyBackButton'),
                  icon: const Icon(Icons.arrow_back),
                  color: _backgroundColor,
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    if (navigator.canPop()) {
                      navigator.pop();
                    } else {
                      navigator.pushReplacementNamed(TootScreen.route);
                    }
                  },
                ),
              ],
              title: AppScreenTitle(
                title: 'TOOT FAIRY',
                color: _backgroundColorSecondary.withValues(alpha: .6),
                shadows: const <Shadow>[
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2.0,
                    color: Color.fromARGB(50, 0, 0, 255),
                  ),
                ],
              ),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                final sceneWidth = isMobile
                    ? constraints.maxWidth
                    : constraints.maxWidth.clamp(0, 720).toDouble();
                final sceneHeight = sceneWidth * 0.82;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: sceneWidth,
                        minHeight: constraints.maxHeight - 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: sceneWidth,
                            height: sceneHeight,
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                RotatingFruits(),
                                Cloud(),
                                TootFairy(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startAudio() async {
    if (_hasStartedAudio) {
      return;
    }
    _hasStartedAudio = true;

    await _audioService.setAudio('asset:///assets/audio/toot_fairy_intro.mp3');
    if (mounted) {
      _audioService.play();
    }
  }
}

import 'dart:async';

import 'package:ad_service/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/widgets/cloud.dart';
import 'package:tootfruit/widgets/rotating_fruit.dart';
import 'package:tootfruit/widgets/toot_fairy.dart';

import '../widgets/screen_title.dart';

class TootFairyScreen extends StatelessWidget {
  static const String route = '/toot_fairy';

  final _audioService = Locator.get<AudioService>();
  late final _tootService = Locator.get<TootService>();
  late final _adService = Locator.get<AdService>();

  static const Color _backgroundColor = Color(0xff53BAF3);
  static const Color _backgroundColorSecondary = Color(0xff43b6f6);
  static const Color _buttonColor = _backgroundColor;

  TootFairyScreen({Key? key}) : super(key: key);

  static Future<void> precacheImages(context) async {
    await precacheImage(
        const AssetImage('assets/images/all_fruits.png'), context);
    await precacheImage(
        const AssetImage('assets/images/clouds_bottom_smaller.png'), context);
    await precacheImage(
        const AssetImage('assets/images/clouds_top_smaller.png'), context);
    await precacheImage(
        const AssetImage('assets/images/cloud_simple.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    _tootService.isRewarded = false;
    _startAudio();
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
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                iconTheme: const IconThemeData(
                  color: _backgroundColor, //change your color here
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: _backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              '${_tootService.owned.length} / ${_tootService.all.length}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                              )),
                          const Text('FRUITS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
                backgroundColor: Colors.transparent,
                centerTitle: true,
                elevation: 0,
                title: AppScreenTitle(
                  title: 'TOOT FAIRY',
                  color: _backgroundColorSecondary.withOpacity(.6),
                  shadows: const <Shadow>[
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2.0,
                      color: Color.fromARGB(50, 0, 0, 255),
                    ),
                  ],
                ),
              ),
              body: Stack(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.top +
                              MediaQuery.of(context).padding.bottom +
                              AppBar().preferredSize.height),
                      child:
                          const Stack(alignment: Alignment.center, children: [
                        RotatingFruits(),
                        Cloud(),
                        TootFairy(),
                      ]),
                    ),
                  ],
                ),
                _tootService.ownsEveryToot
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 24.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            children: [
                              Spacer(),
                              Text('YOU OWN EVERY TOOT FRUIT!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: _backgroundColor, fontSize: 20)),
                              Text('😊 check back later for more 😊',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16)),
                            ],
                          ),
                        ))
                    : Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await _audioService.stop();
                                        _adService.showRewardedAd();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: BeveledRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          side: const BorderSide(
                                            width: 2,
                                            color: Colors.white,
                                          ),
                                          elevation: 10,
                                          backgroundColor: _buttonColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 16),
                                          textStyle: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                      child: const Text("COLLECT MORE",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ]),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8.0, top: 4),
                              child: Text('watch ad for new fruit or',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    shadows: const <Shadow>[
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 2.0,
                                        color: Color.fromARGB(50, 0, 0, 255),
                                      ),
                                    ],
                                    color: _backgroundColorSecondary
                                        .withOpacity(.7),
                                  )),
                            ),
                            OutlinedButton(
                                onPressed: () async {
                                  await _tootService.purchaseAll();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shape: BeveledRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: const BorderSide(
                                      width: 2,
                                      color: _backgroundColorSecondary,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    textStyle: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                child: StreamBuilder<bool>(
                                    stream: _tootService.loading$,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container();
                                      }

                                      return snapshot.requireData
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicator())
                                          : const Text(
                                              "BUY ALL",
                                              style: TextStyle(
                                                color:
                                                    _backgroundColorSecondary,
                                                fontSize: 18,
                                              ),
                                            );
                                    })),
                          ],
                        ),
                      ),
              ]),
            ),
          ),
        ));
  }

  Future<void> _startAudio() async {
    await _audioService.setAudio('asset:///assets/audio/toot_fairy_intro.m4a');
    await _audioService.play();
  }
}

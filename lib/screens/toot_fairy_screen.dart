import 'package:flutter/material.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/screens/toot_loot_screen.dart';
import 'package:tooty_fruity/services/audio_service.dart';
import 'package:tooty_fruity/services/navigation_service.dart';

class TootFairyScreen extends StatefulWidget {
  static const String route = '/toot_fairy';

  const TootFairyScreen({Key? key}) : super(key: key);

  @override
  State<TootFairyScreen> createState() => _TootFairyScreenState();
}

class _TootFairyScreenState extends State<TootFairyScreen> with SingleTickerProviderStateMixin {
  final _audioService = Locator.get<AudioService>();
  late final _navService = Locator.get<NavigationService>();

  static const Color _gold = Color(0xffFFF2A0);
  static const Color _brown = Color(0xff92713E);
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _animationController.repeat(reverse: true);
    _startAudio();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _brown,
        appBar: AppBar(
          leading: Container(),
          centerTitle: true,
          elevation: 0,
          title: Text(
            'Unlock Premium Toots!'.toUpperCase(),
            style: TextStyle(color: Colors.white.withAlpha(80)),
          ),
          backgroundColor: _brown,
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(),
          FadeTransition(
              opacity: _animationController,
              child: const Image(
                image: AssetImage("assets/images/toot_fairy.png"),
              )),
          Text('Watch an ad to unlock a premium toot!',
              style: TextStyle(color: Colors.white.withOpacity(.6))),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  _audioService.stop();
                  _navService.current.pushNamed(TootLootScreen.route);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                child: const Text("WATCH AD", style: TextStyle(color: _brown, fontSize: 36)),
              ),
            ),
          ),
          const Spacer(),
        ]));
  }

  Future<void> _startAudio() async {
    await _audioService.setAudio('asset:///assets/audio/toot_fairy.m4a');
    await _audioService.play();
  }
}

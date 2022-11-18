import 'package:flutter/material.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/services/audio_service.dart';

class TootFairyScreen extends StatefulWidget {
  static const String route = '/toot_fairy';

  const TootFairyScreen({Key? key}) : super(key: key);

  @override
  State<TootFairyScreen> createState() => _TootFairyScreenState();
}

class _TootFairyScreenState extends State<TootFairyScreen> with SingleTickerProviderStateMixin {
  final _audioService = Locator.get<AudioService>();

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
        backgroundColor: const Color(0xff92713E),
        appBar: AppBar(
          leading: Container(),
          centerTitle: true,
          elevation: 0,
          title: Text(
            'Unlock Premium Toots!'.toUpperCase(),
            style: TextStyle(color: Colors.white.withAlpha(80)),
          ),
          backgroundColor: const Color(0xff92713E),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(),
          FadeTransition(
              opacity: _animationController,
              child: const Image(
                image: AssetImage("assets/images/toot_fairy.png"),
              )),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  const Text("COMING SOON", style: TextStyle(color: Colors.white54, fontSize: 36)),
            ),
          ),
          Center(
            child: const Text("Wow, you must be feelin' gassy!",
                style: TextStyle(color: Colors.white)),
          ),
          const Spacer(),
        ]));
  }

  Future<void> _startAudio() async {
    await _audioService.setAudio('asset:///assets/audio/toot_fairy.m4a');
    await _audioService.play();
  }
}

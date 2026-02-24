import 'package:flutter/material.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/widgets/fruit_asset.dart';
import 'package:tootfruit/widgets/screen_title.dart';

import '../models/toot.dart';
import '../services/navigation_service.dart';
import '../widgets/star.dart';

class TootLootScreen extends StatefulWidget {
  static const String route = '/toot_loot';

  const TootLootScreen({super.key});

  @override
  State<TootLootScreen> createState() => _TootLootScreenState();
}

class _TootLootScreenState extends State<TootLootScreen>
    with TickerProviderStateMixin {
  late final _tootService = Locator.get<TootService>();
  late final _navService = Locator.get<NavigationService>();
  late final _audioService = Locator.get<AudioService>();

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _explosionRotationController;
  late AnimationController _explosionRotationController2;
  late AnimationController _explosionRotationController3;
  late AnimationController _explosionRotationController4;
  late AnimationController _explosionRotationController5;
  late AnimationController _explosionRotationController6;
  static const _quick = Duration(milliseconds: 500);
  static const _quicker = Duration(milliseconds: 80);
  double _scale = 0.5;
  double _angle = 0.0;
  static const int _baseRotationSpeed = 2000;
  double _baseSize = 0;
  static const double _baseOpacity = .4;
  static const double _opacityModifier = .05;
  static const int _starPointCount = 10;
  late Toot toot;

  Color _textColor(Toot toot) =>
      toot.darkText ? toot.color.darken(30) : toot.color.lighten(30);
  Color _contrastTextColor(Toot toot) =>
      toot.darkText ? toot.color.darken(50) : toot.color.lighten(50);

  @override
  void initState() {
    super.initState();

    final scaleTween = Tween(begin: _scale, end: .8);
    final rotateTween = Tween(begin: _angle, end: .2);
    _scaleController = AnimationController(duration: _quick, vsync: this)
      ..repeat(reverse: true);
    _rotationController = AnimationController(duration: _quicker, vsync: this)
      ..repeat(reverse: true);

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

    _explosionRotationController = AnimationController(
      duration: const Duration(milliseconds: _baseRotationSpeed * 6),
      vsync: this,
    )..repeat();
    _explosionRotationController2 = AnimationController(
      duration: const Duration(milliseconds: _baseRotationSpeed * 5),
      vsync: this,
    )..repeat();
    _explosionRotationController3 = AnimationController(
      duration: const Duration(milliseconds: _baseRotationSpeed * 4),
      vsync: this,
    )..repeat();
    _explosionRotationController4 = AnimationController(
      duration: const Duration(milliseconds: _baseRotationSpeed * 3),
      vsync: this,
    )..repeat();
    _explosionRotationController5 = AnimationController(
      duration: const Duration(milliseconds: _baseRotationSpeed * 2),
      vsync: this,
    )..repeat();
    _explosionRotationController6 = AnimationController(
      duration: const Duration(milliseconds: _baseRotationSpeed),
      vsync: this,
    )..repeat();
    toot = _tootService.newLoot!;
    _startAudio();
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
    _baseSize = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _navService.current.pushNamed(TootScreen.route),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: toot.color,
          appBar: AppBar(
            leading: Container(),
            centerTitle: true,
            elevation: 0,
            title: AppScreenTitle(color: _textColor(toot), title: 'TOOT LOOT'),
            backgroundColor: toot.color,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                width: _baseSize,
                height: _baseSize,
                child: Stack(
                  clipBehavior: Clip.antiAlias,
                  fit: StackFit.loose,
                  children: [
                    ..._buildStarPattern(),
                    Center(
                      child: Transform.rotate(
                        angle: _angle,
                        child: Transform.scale(
                          scale: _scale,
                          child: SizedBox(
                            width: 400,
                            height: 400,
                            child: FruitAsset(
                              key: ValueKey<String>('loot-fruit-${toot.fruit}'),
                              fruit: toot.fruit,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  toot.title.toUpperCase(),
                  style: TextStyle(
                    color: _contrastTextColor(toot),
                    fontSize: 20,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStarPattern() {
    return [
      RotationTransition(
        turns: Tween(
          begin: 1.0,
          end: 0.0,
        ).animate(_explosionRotationController),
        child: Center(
          child: ClipPath(
            clipper: StarClipper(_starPointCount),
            child: Container(
              width: _baseSize,
              height: _baseSize,
              color: Colors.white.withValues(alpha: _baseOpacity),
            ),
          ),
        ),
      ),
      RotationTransition(
        turns: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(_explosionRotationController2),
        child: Center(
          child: ClipPath(
            clipper: StarClipper(_starPointCount),
            child: Container(
              width: _baseSize,
              height: _baseSize,
              color: Colors.white.withValues(
                alpha: _baseOpacity + (_opacityModifier),
              ),
            ),
          ),
        ),
      ),
      RotationTransition(
        turns: Tween(
          begin: 1.0,
          end: 0.0,
        ).animate(_explosionRotationController3),
        child: Center(
          child: ClipPath(
            clipper: StarClipper(_starPointCount),
            child: Container(
              width: _baseSize / 1.25,
              height: _baseSize / 1.25,
              color: Colors.white.withValues(
                alpha: _baseOpacity + (_opacityModifier * 2),
              ),
            ),
          ),
        ),
      ),
      RotationTransition(
        turns: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(_explosionRotationController4),
        child: Center(
          child: ClipPath(
            clipper: StarClipper(_starPointCount),
            child: Container(
              width: _baseSize / 1.5,
              height: _baseSize / 1.5,
              color: Colors.white.withValues(
                alpha: _baseOpacity + (_opacityModifier * 3),
              ),
            ),
          ),
        ),
      ),
      RotationTransition(
        turns: Tween(
          begin: 1.0,
          end: 0.0,
        ).animate(_explosionRotationController5),
        child: Center(
          child: ClipPath(
            clipper: StarClipper(_starPointCount),
            child: Container(
              width: _baseSize / 1.75,
              height: _baseSize / 1.75,
              color: Colors.white.withValues(
                alpha: _baseOpacity + (_opacityModifier * 4),
              ),
            ),
          ),
        ),
      ),
      RotationTransition(
        turns: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(_explosionRotationController6),
        child: Center(
          child: ClipPath(
            clipper: StarClipper(_starPointCount),
            child: Container(
              width: _baseSize / 2,
              height: _baseSize / 2,
              color: Colors.white.withValues(
                alpha: _baseOpacity + (_opacityModifier * 5),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Future<void> _startAudio() async {
    await _tootService.set(toot);
    _audioService.play();
  }
}

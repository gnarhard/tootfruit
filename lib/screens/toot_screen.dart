import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/screens/toot_fairy_screen.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/toot_service.dart';

import '../models/toot.dart';
import '../services/navigation_service.dart';
import '../widgets/screen_title.dart';

class TootScreen extends StatefulWidget {
  static const String route = '/toot';

  const TootScreen({super.key});
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
  static const double swipeSensitivity = 300;
  static const double desktopWebBreakpoint = 1024;
  late Toot toot;

  Color _textColor(Toot toot) =>
      toot.darkText ? toot.color.darken(30) : toot.color.lighten(30);
  Color _contrastTextColor(Toot toot) =>
      toot.darkText ? toot.color.darken(50) : toot.color.lighten(50);

  @override
  void initState() {
    super.initState();

    final scaleTween = Tween(begin: _scale, end: 1.0);
    final rotateTween = Tween(begin: _angle, end: .5);
    _scaleController = AnimationController(duration: _quick, vsync: this);
    _rotationController = AnimationController(duration: _quicker, vsync: this);
    _opacityController = AnimationController(duration: _long, vsync: this)
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

    _opacityAnimation = CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    toot = _tootService.current;

    return PopScope(
      canPop: false,
      child: GestureDetector(
        key: const Key('tootGestureSurface'),
        onHorizontalDragEnd: (details) async {
          if (details.velocity.pixelsPerSecond.dx < -swipeSensitivity) {
            await _showNextToot();
          } else if (details.velocity.pixelsPerSecond.dx > swipeSensitivity) {
            await _showPreviousToot();
          }
        },
        child: Scaffold(
          key: const Key('tootScreen'),
          backgroundColor: toot.color,
          appBar: AppBar(
            leading: Container(),
            centerTitle: true,
            elevation: 0,
            title: AppScreenTitle(title: toot.title, color: _textColor(toot)),
            backgroundColor: toot.color,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final showDesktopWebNavButtons =
                  kIsWeb && constraints.maxWidth > desktopWebBreakpoint;

              return Stack(
                children: [
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: _tootService.owned.length < 2
                        ? Container()
                        : Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/swipe.png',
                                  height: 48,
                                  width: 48,
                                  color: _textColor(toot),
                                  colorBlendMode: BlendMode.srcATop,
                                  fit: BoxFit.fitWidth,
                                ),
                                Text(
                                  'swipe',
                                  style: TextStyle(color: _textColor(toot)),
                                ),
                              ],
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const minImageSize = 120.0;
                        const maxImageSize = 420.0;
                        const guidanceHeight = 48.0;
                        final maxHeightBasedSize =
                            constraints.maxHeight - guidanceHeight;
                        final maxWidthBasedSize = constraints.maxWidth * 0.7;
                        final preferredImageSize =
                            maxHeightBasedSize < maxWidthBasedSize
                            ? maxHeightBasedSize
                            : maxWidthBasedSize;
                        final imageSize = preferredImageSize
                            .clamp(minImageSize, maxImageSize)
                            .toDouble();

                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.rotate(
                                angle: _angle,
                                child: Transform.scale(
                                  scale: _scale,
                                  child: GestureDetector(
                                    onTap: () => _tootAndAnimate(),
                                    onLongPress: () => _tootAndAnimate(),
                                    child: SizedBox(
                                      width: imageSize,
                                      height: imageSize,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 320,
                                        ),
                                        switchInCurve: Curves.easeOut,
                                        switchOutCurve: Curves.easeOut,
                                        transitionBuilder: (child, animation) =>
                                            FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                        child: SvgPicture.asset(
                                          'assets/images/fruit/${toot.fruit}.svg',
                                          key: ValueKey<String>(toot.fruit),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.cover,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      semanticLabel: 'Up arrow',
                                      color: _contrastTextColor(toot),
                                      size: 14,
                                    ),
                                    Text(
                                      'tap that',
                                      style: TextStyle(
                                        color: _contrastTextColor(toot),
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (showDesktopWebNavButtons)
                    _DesktopWebFruitNavButton(
                      key: const Key('desktopPrevFruitButton'),
                      alignment: Alignment.centerLeft,
                      icon: Icons.chevron_left,
                      onPressed: _showPreviousToot,
                      color: _textColor(toot),
                    ),
                  if (showDesktopWebNavButtons)
                    _DesktopWebFruitNavButton(
                      key: const Key('desktopNextFruitButton'),
                      alignment: Alignment.centerRight,
                      icon: Icons.chevron_right,
                      onPressed: _showNextToot,
                      color: _textColor(toot),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: OutlinedButton(
                        key: const Key('visitTootFairyButton'),
                        onPressed: () {
                          _navService.current.pushNamed(TootFairyScreen.route);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(width: 1, color: _textColor(toot)),
                        ),
                        child: SizedBox(
                          width: 180,
                          height: 24,
                          child: Center(
                            child: Text(
                              'visit the toot fairy',
                              style: TextStyle(
                                color: _textColor(toot),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showNextToot() async {
    _resetAnimations();
    await _tootService.increment();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showPreviousToot() async {
    _resetAnimations();
    await _tootService.decrement();
    if (mounted) {
      setState(() {});
    }
  }

  void _resetAnimations() {
    setState(() {
      _scaleController.stop();
      _rotationController.stop();
      _scale = .7;
      _angle = 0;
    });
  }

  void _animate() {
    final duration = (toot.duration != null && toot.duration! > Duration.zero)
        ? toot.duration!
        : const Duration(milliseconds: 450);

    _rotationController
        .repeat(reverse: true)
        .timeout(
          duration,
          onTimeout: () {
            _rotationController
                .reverse(from: .5)
                .whenComplete(() => _rotationController.stop());
          },
        );

    _scaleController.forward().whenComplete(() => _scaleController.reverse());
  }

  void _tootAndAnimate() {
    _audioService.play();
    _animate();
  }
}

class _DesktopWebFruitNavButton extends StatelessWidget {
  final Alignment alignment;
  final IconData icon;
  final Future<void> Function() onPressed;
  final Color color;

  const _DesktopWebFruitNavButton({
    super.key,
    required this.alignment,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
            ),
            child: IconButton(
              iconSize: 40,
              splashRadius: 30,
              color: color,
              icon: Icon(icon),
              onPressed: () async {
                await onPressed();
              },
            ),
          ),
        ),
      ),
    );
  }
}

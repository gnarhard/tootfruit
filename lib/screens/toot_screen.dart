import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/screens/toot_fairy_screen.dart';
import 'package:tootfruit/services/toot_transition.dart';
import 'package:tootfruit/widgets/fruit_asset.dart';

import '../models/toot.dart';
import '../widgets/screen_title.dart';

class TootScreen extends StatefulWidget {
  static const String route = '/toot';

  const TootScreen({super.key});
  static const double startingFontSize = 130;

  @override
  TootScreenState createState() => TootScreenState();
}

class TootScreenState extends State<TootScreen> with TickerProviderStateMixin {
  final _di = DI();

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
  static const Duration _pageTransitionDuration = Duration(milliseconds: 320);
  late Toot toot;
  late Toot _fromToot;
  int _transitionTick = 0;
  bool _keyboardHandlerAttached = false;
  bool _isKeyboardNavigating = false;
  bool _isDisposed = false;

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

    toot = _di.tootService.current;
    _fromToot = toot;

    if (_supportsSpacebarActivation) {
      HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
      _keyboardHandlerAttached = true;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_keyboardHandlerAttached) {
      HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
      _keyboardHandlerAttached = false;
    }
    _scaleController.dispose();
    _rotationController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromToot = _fromToot;
    final toToot = toot;

    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(_transitionTick),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: _pageTransitionDuration,
      curve: Curves.linear,
      builder: (context, animationValue, _) {
        final fruitTransitionProgress = linearFruitTransitionProgress(
          fromFruit: fromToot.fruit,
          toFruit: toToot.fruit,
          animationValue: animationValue,
        );
        final backgroundColor = lerpFruitPageColor(
          fromColor: fromToot.color,
          toColor: toToot.color,
          progress: fruitTransitionProgress,
        );
        final textColor = lerpFruitPageColor(
          fromColor: _textColor(fromToot),
          toColor: _textColor(toToot),
          progress: fruitTransitionProgress,
        );
        final contrastTextColor = lerpFruitPageColor(
          fromColor: _contrastTextColor(fromToot),
          toColor: _contrastTextColor(toToot),
          progress: fruitTransitionProgress,
        );

        return PopScope(
          canPop: false,
          child: GestureDetector(
            key: const Key('tootGestureSurface'),
            onHorizontalDragEnd: (details) async {
              if (details.velocity.pixelsPerSecond.dx < -swipeSensitivity) {
                await _showNextToot();
              } else if (details.velocity.pixelsPerSecond.dx >
                  swipeSensitivity) {
                await _showPreviousToot();
              }
            },
            child: Scaffold(
              key: const Key('tootScreen'),
              backgroundColor: backgroundColor,
              appBar: AppBar(
                leading: Container(),
                centerTitle: true,
                elevation: 0,
                title: AppScreenTitle(title: toToot.title, color: textColor),
                backgroundColor: backgroundColor,
              ),
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final showDesktopWebNavButtons =
                      kIsWeb && constraints.maxWidth > desktopWebBreakpoint;

                  return Stack(
                    children: [
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: _di.tootService.all.length < 2
                            ? Container()
                            : Center(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/swipe.png',
                                      height: 48,
                                      width: 48,
                                      color: textColor,
                                      colorBlendMode: BlendMode.srcATop,
                                      fit: BoxFit.fitWidth,
                                    ),
                                    Text(
                                      'swipe',
                                      style: TextStyle(color: textColor),
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
                            final maxWidthBasedSize =
                                constraints.maxWidth * 0.7;
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
                                      key: const Key('fruitScaleTransform'),
                                      scale: _scale,
                                      child: GestureDetector(
                                        onTap: () {
                                          unawaited(_tootAndAnimate());
                                        },
                                        onLongPress: () {
                                          unawaited(_tootAndAnimate());
                                        },
                                        child: SizedBox(
                                          width: imageSize,
                                          height: imageSize,
                                          child: _buildTransitioningFruit(
                                            fromToot: fromToot,
                                            toToot: toToot,
                                            progress: fruitTransitionProgress,
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
                                          color: contrastTextColor,
                                          size: 14,
                                        ),
                                        Text(
                                          'tap that',
                                          style: TextStyle(
                                            color: contrastTextColor,
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
                          color: textColor,
                        ),
                      if (showDesktopWebNavButtons)
                        _DesktopWebFruitNavButton(
                          key: const Key('desktopNextFruitButton'),
                          alignment: Alignment.centerRight,
                          icon: Icons.chevron_right,
                          onPressed: _showNextToot,
                          color: textColor,
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: OutlinedButton(
                            key: const Key('visitTootFairyButton'),
                            onPressed: () {
                              _di.navigationService.current.pushNamed(
                                TootFairyScreen.route,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(width: 1, color: textColor),
                            ),
                            child: SizedBox(
                              width: 180,
                              height: 24,
                              child: Center(
                                child: Text(
                                  'visit the toot fairy',
                                  style: TextStyle(
                                    color: textColor,
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
      },
    );
  }

  Widget _buildTransitioningFruit({
    required Toot fromToot,
    required Toot toToot,
    required double progress,
  }) {
    if (fromToot.fruit == toToot.fruit) {
      return FruitAsset(
        key: ValueKey<String>('fruit-${toToot.fruit}'),
        fruit: toToot.fruit,
        svgKey: ValueKey<String>('fruit-svg-${toToot.fruit}'),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 1.0 - progress,
          child: IgnorePointer(
            child: FruitAsset(
              key: ValueKey<String>(
                'fruit-from-${fromToot.fruit}-$_transitionTick',
              ),
              fruit: fromToot.fruit,
              svgKey: ValueKey<String>(
                'fruit-from-svg-${fromToot.fruit}-$_transitionTick',
              ),
            ),
          ),
        ),
        Opacity(
          opacity: progress,
          child: Transform.rotate(
            angle: fadeInFruitRotationRadians(progress: progress),
            child: Transform.scale(
              scale: fadeInFruitScale(progress: progress),
              child: FruitAsset(
                key: ValueKey<String>(
                  'fruit-to-${toToot.fruit}-$_transitionTick',
                ),
                fruit: toToot.fruit,
                svgKey: ValueKey<String>(
                  'fruit-to-svg-${toToot.fruit}-$_transitionTick',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showNextToot() async {
    final previousToot = toot;
    _resetAnimations();
    await _di.tootService.increment();
    if (mounted) {
      setState(() {
        _fromToot = previousToot;
        toot = _di.tootService.current;
        _transitionTick++;
      });
    }
  }

  Future<void> _showPreviousToot() async {
    final previousToot = toot;
    _resetAnimations();
    await _di.tootService.decrement();
    if (mounted) {
      setState(() {
        _fromToot = previousToot;
        toot = _di.tootService.current;
        _transitionTick++;
      });
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
            if (!mounted || _isDisposed) {
              return;
            }
            _rotationController.reverse(from: .5).whenComplete(() {
              if (!mounted || _isDisposed) {
                return;
              }
              _rotationController.stop();
            });
          },
        );

    _scaleController.forward().whenComplete(() {
      if (!mounted || _isDisposed) {
        return;
      }
      _scaleController.reverse();
    });
  }

  Future<void> _tootAndAnimate() async {
    await _di.tootService.ensureCurrentAudioPrepared();
    if (!mounted) {
      return;
    }
    _di.audioPlayer.play();
    _animate();
  }

  bool get _supportsSpacebarActivation =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (!_supportsSpacebarActivation || !mounted) {
      return false;
    }

    final isSpace = event.logicalKey == LogicalKeyboardKey.space;
    final isRightArrow = event.logicalKey == LogicalKeyboardKey.arrowRight;
    final isLeftArrow = event.logicalKey == LogicalKeyboardKey.arrowLeft;

    if (isSpace) {
      final isPress = event is KeyDownEvent || event is KeyRepeatEvent;
      if (!isPress) {
        return false;
      }
      unawaited(_tootAndAnimate());
      return true;
    }

    if (!isRightArrow && !isLeftArrow) {
      return false;
    }

    if (event is! KeyDownEvent) {
      return true;
    }
    if (_isKeyboardNavigating) {
      return true;
    }

    _isKeyboardNavigating = true;
    final navigationFuture = isRightArrow
        ? _showNextToot()
        : _showPreviousToot();
    unawaited(
      navigationFuture.whenComplete(() {
        _isKeyboardNavigating = false;
      }),
    );
    return true;
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

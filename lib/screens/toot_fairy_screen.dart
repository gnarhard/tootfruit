import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/widgets/cloud.dart';
import 'package:tootfruit/widgets/fruit_asset.dart';
import 'package:tootfruit/widgets/rotating_fruit.dart';
import 'package:tootfruit/widgets/toot_fairy.dart';

class TootFairyScreen extends StatefulWidget {
  static const String route = '/toot_fairy';

  const TootFairyScreen({super.key});

  @override
  State<TootFairyScreen> createState() => _TootFairyScreenState();
}

class _FallingFruit {
  final Toot toot;
  final double x; // 0..1 fraction of width
  double y; // pixels from top
  final int id;
  final double size;
  final double rotationSpeed; // radians per second
  double rotation = 0; // current rotation in radians

  _FallingFruit({
    required this.toot,
    required this.x,
    required this.y,
    required this.id,
    required this.rotationSpeed,
    this.size = 70,
  });
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double opacity;
  double lifetime;
  double maxLifetime;
  Color color;
  double size;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.maxLifetime,
  }) : opacity = 1.0,
       lifetime = 0;
}

class _PopEffect {
  final double x;
  final double y;
  final double size;
  double lifetime;
  final double maxLifetime;

  _PopEffect({required this.x, required this.y, required this.size})
    : lifetime = 0,
      maxLifetime = 0.2;

  double get scale {
    final t = (lifetime / maxLifetime).clamp(0.0, 1.0);
    if (t < 0.5) return 1.0 + 0.3 * (t / 0.5);
    return 1.3 * (1.0 - ((t - 0.5) / 0.5));
  }

  double get opacity => (1.0 - (lifetime / maxLifetime)).clamp(0.0, 1.0);
}

class _TootFairyScreenState extends State<TootFairyScreen>
    with SingleTickerProviderStateMixin {
  static const Color _backgroundColor = Color(0xff53BAF3);
  static const Color _backgroundColorSecondary = Color(0xff43b6f6);
  static const double _initialFallSpeed = 180; // pixels per second
  static const double _initialSpawnInterval = 1.5; // seconds
  static const double _difficultyMultiplier = 0.85; // 15% faster every 5s
  static const double _fallSpeedIncrease = 25; // extra px/s every 5s

  final _di = DI();
  final _random = Random();

  late Ticker _ticker;
  Duration _lastTick = Duration.zero;

  final List<_FallingFruit> _fruits = [];
  final List<_Particle> _particles = [];
  final List<_PopEffect> _pops = [];
  final List<Toot> _snaggedFruits = [];
  int _score = 0;
  double _fallSpeed = _initialFallSpeed;
  bool _isGameOver = false;
  bool _isStarted = false;
  int _nextId = 0;

  double _spawnInterval = _initialSpawnInterval;
  double _timeSinceLastSpawn = 0;
  double _totalElapsed = 0;
  double _lastDifficultyTime = 0;

  // Game over animation state
  double _overlayOpacity = 0;
  double _gameOverTextOffset = -100;
  double _scoreScale = 0;
  int _displayScore = 0;
  double _buttonsOpacity = 0;
  double _gameOverAnimTime = 0;
  bool _gameOverAnimDone = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _startTootFairyAudio();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _di.audioPlayer.stop();
    super.dispose();
  }

  Future<void> _playButtonSound() async {
    try {
      await _di.audioPlayer.setAudio('asset:///assets/audio/fart_button.mp3');
      _di.audioPlayer.play();
    } catch (_) {}
  }

  Future<void> _startTootFairyAudio() async {
    try {
      await _di.audioPlayer.setAudio(
        'asset:///assets/audio/toot_fairy_intro.mp3',
      );
      _di.audioPlayer.play();
    } catch (_) {
      // Audio errors shouldn't prevent the screen from loading
    }
  }

  void _startGame() {
    setState(() {
      _fruits.clear();
      _particles.clear();
      _pops.clear();
      _snaggedFruits.clear();
      _score = 0;
      _fallSpeed = _initialFallSpeed;
      _isGameOver = false;
      _isStarted = true;
      _nextId = 0;
      _spawnInterval = _initialSpawnInterval;
      _timeSinceLastSpawn = 0;
      _totalElapsed = 0;
      _lastDifficultyTime = 0;
      _lastTick = Duration.zero;
      _overlayOpacity = 0;
      _gameOverTextOffset = -100;
      _scoreScale = 0;
      _displayScore = 0;
      _buttonsOpacity = 0;
      _gameOverAnimTime = 0;
      _gameOverAnimDone = false;
    });
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }

    final dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    if (_isGameOver) {
      _updateGameOverAnimation(dt);
      return;
    }

    setState(() {
      _totalElapsed += dt;

      // Increase difficulty every 5 seconds
      if (_totalElapsed - _lastDifficultyTime >= 5.0) {
        _spawnInterval *= _difficultyMultiplier;
        _fallSpeed += _fallSpeedIncrease;
        _lastDifficultyTime = _totalElapsed;
      }

      // Spawn new fruits
      _timeSinceLastSpawn += dt;
      if (_timeSinceLastSpawn >= _spawnInterval) {
        _timeSinceLastSpawn = 0;
        _spawnFruit();
      }

      // Update fruit positions and rotations
      for (final fruit in _fruits) {
        fruit.y += _fallSpeed * dt;
        fruit.rotation += fruit.rotationSpeed * dt;
      }

      // Update particles
      _updateParticles(dt);

      // Update pop effects
      _pops.removeWhere((pop) {
        pop.lifetime += dt;
        return pop.lifetime >= pop.maxLifetime;
      });

      // Check game over — use play area height from layout
      // We'll check against a stored height; default to a large value
      final maxY = _playAreaHeight ?? 800;
      for (final fruit in _fruits) {
        if (fruit.y + fruit.size >= maxY) {
          _triggerGameOver();
          return;
        }
      }
    });
  }

  double? _playAreaHeight;
  double? _playAreaWidth;

  void _spawnFruit() {
    final toot = toots[_random.nextInt(toots.length)];
    final fruitSize = 60.0 + _random.nextDouble() * 20;
    // Random rotation speed: 1–4 rad/s, randomly clockwise or counter-clockwise
    final speed = 1.0 + _random.nextDouble() * 3.0;
    final direction = _random.nextBool() ? 1.0 : -1.0;
    _fruits.add(
      _FallingFruit(
        toot: toot,
        x: _random.nextDouble(),
        y: -fruitSize,
        id: _nextId++,
        size: fruitSize,
        rotationSpeed: speed * direction,
      ),
    );
  }

  void _onFruitTap(_FallingFruit fruit) {
    if (_isGameOver) return;

    setState(() {
      _fruits.remove(fruit);
      _score++;
      _snaggedFruits.add(fruit.toot);

      // Spawn pop effect (uses fractional x like fruits)
      _pops.add(_PopEffect(x: fruit.x, y: fruit.y, size: fruit.size));

      // Spawn particles in absolute pixel coords
      final areaW = _playAreaWidth ?? 400;
      final centerX = fruit.x * (areaW - fruit.size) + fruit.size / 2;
      final centerY = fruit.y + fruit.size / 2;
      final particleCount = 8 + _random.nextInt(5);
      for (var i = 0; i < particleCount; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 80 + _random.nextDouble() * 160;
        _particles.add(
          _Particle(
            x: centerX,
            y: centerY,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed,
            color: fruit.toot.color,
            size: 4 + _random.nextDouble() * 6,
            maxLifetime: 0.3 + _random.nextDouble() * 0.2,
          ),
        );
      }
    });

    // Play audio
    unawaited(_playTootSound(fruit.toot));
  }

  Future<void> _playTootSound(Toot toot) async {
    try {
      await _di.audioPlayer.setAudio(
        'asset:///assets/audio/${toot.fruit}.${toot.fileExtension}',
      );
      _di.audioPlayer.play();
    } catch (_) {
      // Audio errors shouldn't crash the game
    }
  }

  void _updateParticles(double dt) {
    _particles.removeWhere((p) {
      p.lifetime += dt;
      if (p.lifetime >= p.maxLifetime) return true;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.opacity = (1.0 - (p.lifetime / p.maxLifetime)).clamp(0.0, 1.0);
      p.size *= (1.0 - dt * 2).clamp(0.5, 1.0);
      return false;
    });
  }

  void _triggerGameOver() {
    _isGameOver = true;
    _gameOverAnimTime = 0;
    _gameOverAnimDone = false;
  }

  void _updateGameOverAnimation(double dt) {
    setState(() {
      _gameOverAnimTime += dt;

      // Overlay fades in over 0.3s
      _overlayOpacity = (_gameOverAnimTime / 0.3).clamp(0.0, 1.0);

      // "GAME OVER" drops in from above with overshoot (0.1s - 0.6s)
      if (_gameOverAnimTime > 0.1) {
        final t = ((_gameOverAnimTime - 0.1) / 0.5).clamp(0.0, 1.0);
        // Overshoot curve
        final curved = t < 0.7
            ? (t / 0.7) * 1.15
            : 1.15 - 0.15 * ((t - 0.7) / 0.3);
        _gameOverTextOffset = -100 + curved * 100;
      }

      // Score bounces in (0.3s - 0.6s)
      if (_gameOverAnimTime > 0.3) {
        final t = ((_gameOverAnimTime - 0.3) / 0.3).clamp(0.0, 1.0);
        if (t < 0.7) {
          _scoreScale = (t / 0.7) * 1.1;
        } else {
          _scoreScale = 1.1 - 0.1 * ((t - 0.7) / 0.3);
        }
      }

      // Score counts up (0.3s - 1.3s)
      if (_gameOverAnimTime > 0.3 && _score > 0) {
        final t = ((_gameOverAnimTime - 0.3) / 1.0).clamp(0.0, 1.0);
        _displayScore = (t * _score).round();
      }

      // Buttons fade in after 1.2s
      if (_gameOverAnimTime > 1.2) {
        _buttonsOpacity = ((_gameOverAnimTime - 1.2) / 0.3).clamp(0.0, 1.0);
      }

      if (_gameOverAnimTime > 1.5 && !_gameOverAnimDone) {
        _gameOverAnimDone = true;
        _displayScore = _score;
        _ticker.stop();
      }
    });
  }

  void _shareScore() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'I tooted $_score fruits in Toot Fairy! \u{1F4A8}\u{1F9DA} Play at tootfruit.com',
      ),
    );
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
            extendBodyBehindAppBar: false,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: _backgroundColor),
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              centerTitle: true,
              toolbarHeight: 80,
              elevation: 0,
              leading: IconButton(
                key: const Key('tootFairyBackButton'),
                icon: const Icon(Icons.arrow_back),
                color: _backgroundColor,
                onPressed: () {
                  unawaited(_playButtonSound());
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) {
                    navigator.pop();
                  } else {
                    navigator.pushReplacementNamed(TootScreen.route);
                  }
                },
              ),
              title: Text(
                'TOOT FAIRY',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
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
              actions: [
                if (_isStarted)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        '$_score',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: _backgroundColorSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: _isStarted ? _buildPlayArea() : _buildStartScreen(),
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final sceneWidth = isMobile
            ? constraints.maxWidth
            : constraints.maxWidth.clamp(0, 720).toDouble();
        final sceneHeight = sceneWidth * 0.82;

        return Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: sceneWidth,
                  height: sceneHeight,
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [RotatingFruits(), Cloud(), TootFairy()],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      unawaited(_playButtonSound());
                      _startGame();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(width: 1, color: _backgroundColor),
                    ),
                    child: SizedBox(
                      width: 180,
                      height: 24,
                      child: Center(
                        child: Text(
                          'PLAY',
                          style: TextStyle(
                            color: _backgroundColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the fruits before\nthey reach the bottom!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _playAreaHeight = constraints.maxHeight;
        _playAreaWidth = constraints.maxWidth;
        final areaWidth = constraints.maxWidth;

        return Stack(
          children: [
            // Falling fruits with circular hitboxes
            for (final fruit in _fruits)
              () {
                const hitPadding = 16.0;
                final hitSize = fruit.size + hitPadding * 2;
                return Positioned(
                  left: fruit.x * (areaWidth - fruit.size) - hitPadding,
                  top: fruit.y - hitPadding,
                  width: hitSize,
                  height: hitSize,
                  child: _CircleHitBox(
                    onTap: () => _onFruitTap(fruit),
                    child: Padding(
                      padding: const EdgeInsets.all(hitPadding),
                      child: Transform.rotate(
                        angle: fruit.rotation,
                        child: FruitAsset(fruit: fruit.toot.fruit),
                      ),
                    ),
                  ),
                );
              }(),

            // Pop effects (fruit scaling up then vanishing)
            for (final pop in _pops)
              Positioned(
                left: pop.x * (areaWidth - pop.size),
                top: pop.y,
                width: pop.size,
                height: pop.size,
                child: Opacity(
                  opacity: pop.opacity,
                  child: Transform.scale(
                    scale: pop.scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),

            // Particles
            for (final p in _particles)
              Positioned(
                left: p.x - p.size / 2,
                top: p.y - p.size / 2,
                child: Opacity(
                  opacity: p.opacity,
                  child: Container(
                    width: p.size,
                    height: p.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.color,
                    ),
                  ),
                ),
              ),

            // Game over overlay
            if (_isGameOver) _buildGameOverOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: _overlayOpacity * 0.6),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              Colors.black.withValues(alpha: _overlayOpacity * 0.7),
              Colors.black.withValues(alpha: _overlayOpacity * 0.3),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // GAME OVER text drops in
            Transform.translate(
              offset: Offset(0, _gameOverTextOffset),
              child: Opacity(
                opacity: _overlayOpacity,
                child: const Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 6.0,
                        color: Color.fromARGB(120, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Score with bounce
            Transform.scale(
              scale: _scoreScale,
              child: Column(
                children: [
                  const Text(
                    'SCORE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    '$_displayScore',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 8.0,
                          color: Color.fromARGB(100, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Snagged fruit emojis
            if (_snaggedFruits.isNotEmpty)
              Opacity(
                opacity: _overlayOpacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      ..._snaggedFruits
                          .take(100)
                          .map(
                            (t) => Text(
                              t.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                      if (_snaggedFruits.length > 100)
                        Text(
                          ' +${_snaggedFruits.length - 100} more',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // Buttons
            Opacity(
              opacity: _buttonsOpacity,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _buttonsOpacity > 0.5
                        ? () {
                            unawaited(_playButtonSound());
                            _shareScore();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(width: 1, color: Colors.white),
                    ),
                    child: const SizedBox(
                      width: 180,
                      height: 24,
                      child: Center(
                        child: Text(
                          'SHARE',
                          style: TextStyle(
                            color: _backgroundColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _buttonsOpacity > 0.5
                        ? () {
                            unawaited(_playButtonSound());
                            _startGame();
                          }
                        : null,
                    child: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that clips hit-testing to a circle, so only taps within the
/// circular area register. Uses [GestureDetector] with opaque behavior
/// so the full circle is tappable even on transparent pixels.
class _CircleHitBox extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleHitBox({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

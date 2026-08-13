import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_strings.dart';
import '../utils/app_images.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

// ── Palette — matches website exactly ────────────────────────────────────────
const _black      = Color(0xFF000000);
const _gold       = Color(0xFFC89030);
const _goldBright = Color(0xFFF2C44A);
const _amber      = Color(0xFFE8A020);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _templeCtrl;
  late AnimationController _textCtrl;
  late AnimationController _omCtrl;
  late AnimationController _gurujiCtrl;

  late Animation<double> _templeOpacity;
  late Animation<double> _templeScale;
  late Animation<double> _glowOpacity;
  late Animation<double> _hindiOpacity;
  late Animation<double> _titleReveal;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _gurujiOpacity;
  late Animation<double> _gurujiSlide;
  @override
  void initState() {
    super.initState();

    _templeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200));
    _omCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);

    _templeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _templeCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeIn)));
    _templeScale = Tween<double>(begin: 1.07, end: 1.0).animate(
        CurvedAnimation(parent: _templeCtrl,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOut)));
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _templeCtrl,
            curve: const Interval(0.4, 1.0, curve: Curves.easeIn)));

    _hindiOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _titleReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl,
            curve: const Interval(0.25, 0.78, curve: Curves.easeInOutCubic)));
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl,
            curve: const Interval(0.68, 1.0, curve: Curves.easeIn)));

    _gurujiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _gurujiOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _gurujiCtrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _gurujiSlide = Tween<double>(begin: -280.0, end: 0.0).animate(
        CurvedAnimation(parent: _gurujiCtrl, curve: Curves.easeOutExpo));

    _templeCtrl.forward();
    Future.delayed(const Duration(milliseconds: 700),
            () { if (mounted) _textCtrl.forward(); });
    // fire after top text is fully done (700ms delay + 3200ms textCtrl)
    Future.delayed(const Duration(milliseconds: 3900),
            () { if (mounted) _gurujiCtrl.forward(); });

    // Restore session in parallel with the splash animation
    AuthService.restoreSession();

    Timer(const Duration(milliseconds: 8000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, a, __) => const HomeScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ));
      }
    });
  }

  @override
  void dispose() {
    _templeCtrl.dispose();
    _textCtrl.dispose();
    _omCtrl.dispose();
    _gurujiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _black,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ── OM watermarks ────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _omCtrl,
            builder: (_, __) => CustomPaint(
              painter: _OmPainter(pulse: _omCtrl.value),
              size: size,
            ),
          ),

          // ── Temple image ─────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _templeCtrl,
            builder: (_, child) => Opacity(
              opacity: _templeOpacity.value,
              child: Transform.scale(scale: _templeScale.value, child: child),
            ),
            child: kIsWeb
                ? Image.network(
                    AppImages.url('temple_golden.png'),
                    fit: BoxFit.cover,
                    width: size.width,
                    height: size.height,
                    alignment: const Alignment(0.3, -1.0),
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  )
                : CachedNetworkImage(
                    imageUrl: AppImages.url('temple_golden.png'),
                    fit: BoxFit.cover,
                    width: size.width,
                    height: size.height,
                    alignment: const Alignment(0.3, -1.0),
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
          ),

          // ── Top vignette ─────────────────────────────────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: const Alignment(0, 0.30),
                colors: [Colors.black.withValues(alpha: 0.70), Colors.transparent],
              ),
            ),
          ),

          // ── Bottom black + golden glow ────────────────────────────────────
          AnimatedBuilder(
            animation: _glowOpacity,
            builder: (_, __) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: const Alignment(0, 0.3),
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.25, 1.0],
                ),
              ),
            ),
          ),

          // ── Golden ground glow ────────────────────────────────────────────
          AnimatedBuilder(
            animation: _glowOpacity,
            builder: (_, __) => Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: size.height * 0.30,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 1.3),
                    radius: 1.0,
                    colors: [
                      _amber.withValues(alpha: 0.20 * _glowOpacity.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Guruji name — bottom center ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: AnimatedBuilder(
                animation: _gurujiCtrl,
                builder: (_, __) => Opacity(
                  opacity: _gurujiOpacity.value,
                  child: Transform.translate(
                    offset: Offset(_gurujiSlide.value, 0),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 38),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Thin gold separator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 52, height: 0.8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, _gold.withValues(alpha: 0.65)],
                                  ),
                                ),
                              ),
                              Container(
                                width: 5, height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 9),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _goldBright,
                                ),
                              ),
                              Container(
                                width: 52, height: 0.8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_gold.withValues(alpha: 0.65), Colors.transparent],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          // Guruji name — elegant italic serif style
                          Text(
                            AppStrings.gurujiName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.4,
                              height: 1.2,
                              shadows: [
                                Shadow(color: _gold.withValues(alpha: 0.85), blurRadius: 20),
                                Shadow(color: _amber.withValues(alpha: 0.4), blurRadius: 44),
                                const Shadow(color: Colors.black54, blurRadius: 8),
                              ],
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'V E D I C   P U R O H I T   ·   T R I M B A K E S H W A R',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white.withValues(alpha: 0.40),
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Text block — top left ────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 52, 28, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Hindi title
                    AnimatedBuilder(
                      animation: _hindiOpacity,
                      builder: (_, child) =>
                          Opacity(opacity: _hindiOpacity.value, child: child),
                      child: Text(
                        'श्री त्र्यंबकेश्वर ज्योतिर्लिंग',
                        style: TextStyle(
                          fontSize: 19,
                          color: _goldBright,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: _gold.withValues(alpha: 0.8),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // TRIMBAKESHWAR — writing reveal
                    AnimatedBuilder(
                      animation: _titleReveal,
                      builder: (_, child) {
                        final p = _titleReveal.value;
                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            ClipRect(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                widthFactor: p,
                                child: child,
                              ),
                            ),
                            if (p > 0.01 && p < 0.99)
                              FractionallySizedBox(
                                widthFactor: p,
                                alignment: Alignment.centerLeft,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    width: 3,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          _goldBright,
                                          _amber,
                                          _goldBright,
                                          Colors.transparent,
                                        ],
                                        stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _goldBright.withValues(alpha: 0.9),
                                          blurRadius: 16,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                      child: const Text(
                        'TRIMBAKESHWAR',
                        style: TextStyle(
                          fontFamily: 'Samarkan',
                          fontSize: 42,
                          color: _amber,
                          letterSpacing: 2,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Color(0xCCC89030),
                              blurRadius: 28,
                              offset: Offset(0, 2),
                            ),
                            Shadow(
                              color: Color(0x55E8A020),
                              blurRadius: 52,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Gold divider line
                    AnimatedBuilder(
                      animation: _subtitleOpacity,
                      builder: (_, __) => Opacity(
                        opacity: _subtitleOpacity.value,
                        child: Container(
                          width: 55,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_gold, Colors.transparent]),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // JYOTIRLINGA • NASHIK • MAHARASHTRA
                    AnimatedBuilder(
                      animation: _subtitleOpacity,
                      builder: (_, child) =>
                          Opacity(opacity: _subtitleOpacity.value, child: child),
                      child: Text(
                        'JYOTIRLINGA  •  NASHIK  •  MAHARASHTRA',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.72),
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── OM watermark painter ──────────────────────────────────────────────────────
class _OmPainter extends CustomPainter {
  final double pulse;
  _OmPainter({required this.pulse});

  static const _positions = [
    Offset(0.07, 0.06), Offset(0.20, 0.13), Offset(0.80, 0.07),
    Offset(0.93, 0.17), Offset(0.04, 0.32), Offset(0.90, 0.38),
    Offset(0.14, 0.68), Offset(0.80, 0.62), Offset(0.50, 0.04),
  ];
  static const _sizes = [
    26.0, 17.0, 30.0, 19.0, 21.0, 25.0, 15.0, 22.0, 19.0,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < _positions.length; i++) {
      final alpha = (0.035 + 0.022 * math.sin(pulse * math.pi + i * 0.9))
          .clamp(0.0, 1.0);
      tp.text = TextSpan(
        text: 'ॐ',
        style: TextStyle(
          fontSize: _sizes[i],
          color: _gold.withValues(alpha: alpha),
          fontWeight: FontWeight.bold,
        ),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          _positions[i].dx * size.width - tp.width / 2,
          _positions[i].dy * size.height - tp.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_OmPainter old) => old.pulse != pulse;
}

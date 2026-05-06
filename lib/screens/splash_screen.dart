import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import 'login_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundCtrl;
  late AnimationController _dragonCtrl;
  late AnimationController _textCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _backgroundFade;
  late Animation<double> _circleScale;
  late Animation<double> _logoSlide;
  late Animation<double> _logoFade;
  late Animation<double> _taglineFade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _backgroundCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _dragonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _backgroundFade = CurvedAnimation(
      parent: _backgroundCtrl,
      curve: Curves.easeOut,
    );

    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dragonCtrl,
        curve: const Interval(0.0, 0.15, curve: Curves.elasticOut),
      ),
    );

    _logoSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _backgroundCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _dragonCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1600));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    _navigateToLogin();
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _backgroundCtrl.dispose();
    _dragonCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.saffronDeep,
      body: FadeTransition(
        opacity: _backgroundFade,
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: Stack(
            children: [
              // Subtle radial glow at the very top
              Positioned(
                top: -size.height * 0.1,
                left: size.width * 0.1,
                right: size.width * 0.1,
                child: AnimatedBuilder(
                  animation: _backgroundFade,
                  builder: (_, _) => Container(
                    height: size.height * 0.55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.saffron
                              .withValues(alpha: 0.08 * _backgroundFade.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Main content
              Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Charo logo figures
                    AnimatedBuilder(
                      animation: Listenable.merge(
                          [_dragonCtrl, _pulseCtrl, _circleScale]),
                      builder: (_, _) {
                        final circleSize =
                            math.min(size.width * 0.65, size.height * 0.48);
                        return Transform.scale(
                          scale: _circleScale.value * _pulse.value,
                          child: SizedBox(
                            width: circleSize,
                            height: circleSize,
                            child: CustomPaint(
                              size: Size(circleSize, circleSize),
                              painter: const _CharoFiguresPainter(),
                            ),
                          ),
                        );
                      },
                    ).animate()
                      .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                      .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.easeOut),

                    SizedBox(height: size.height * 0.04),

                    // App name
                    AnimatedBuilder(
                      animation: _textCtrl,
                      builder: (_, _) => Transform.translate(
                        offset: Offset(0, _logoSlide.value),
                        child: Opacity(
                          opacity: _logoFade.value,
                          child: Column(
                            children: [
                              Text(
                                'charo',
                                style: GoogleFonts.poppins(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Gold divider line with diamonds
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _GoldDividerLine(),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: AppColors.gold,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _GoldDividerLine(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate(delay: 400.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOut),

                    SizedBox(height: size.height * 0.02),

                    // Tagline
                    AnimatedBuilder(
                      animation: _textCtrl,
                      builder: (_, _) => Opacity(
                        opacity: _taglineFade.value,
                        child: Column(
                          children: [
                            // Dzongkha script
                            Text(
                              'འབྲུག་ཡུལ།',
                              style: TextStyle(
                                fontSize: 22,
                                color: AppColors.gold.withValues(alpha: 0.85),
                                letterSpacing: 2,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Connecting Bhutan',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.cream.withValues(alpha: 0.55),
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: 700.ms)
                      .fadeIn(duration: 600.ms),
                  ],
                ),
                ),
              ),

              // Bottom branding
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _taglineFade.value * 0.5,
                    child: Text(
                      'Made in Bhutan 🇧🇹',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.cream.withValues(alpha: 0.4),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharoFiguresPainter extends CustomPainter {
  const _CharoFiguresPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Origin shifted slightly down so heads don't clip at top
    canvas.translate(size.width / 2, size.height / 2 + 15);

    final whiteFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final whiteAlphaFill = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final connectStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final leftArmStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // ── Right figure (drawn first — behind left) ──────────────────────
    canvas.drawCircle(const Offset(40, -114), 25, whiteAlphaFill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(18, -86, 62, 22),
        const Radius.circular(18),
      ),
      whiteAlphaFill,
    );

    // ── Connecting arm (left figure's right arm wrapping around right) ─
    final connectPath = Path()
      ..moveTo(-15, -62)
      ..cubicTo(5, -74, 35, -70, 55, -56)
      ..cubicTo(65, -48, 67, -40, 65, -32);
    canvas.drawPath(connectPath, connectStroke);

    // ── Left figure (in front) ────────────────────────────────────────
    canvas.drawCircle(const Offset(-40, -110), 28, whiteFill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(-65, -82, -15, 26),
        const Radius.circular(22),
      ),
      whiteFill,
    );

    // Left arm extended outward
    final leftArmPath = Path()
      ..moveTo(-65, -60)
      ..quadraticBezierTo(-82, -44, -95, -22);
    canvas.drawPath(leftArmPath, leftArmStroke);
  }

  @override
  bool shouldRepaint(_CharoFiguresPainter _) => false;
}

class _GoldDividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.0),
            AppColors.gold.withValues(alpha: 0.8),
          ],
        ),
      ),
    );
  }
}

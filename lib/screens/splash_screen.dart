import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Background
  late AnimationController _bgCtrl;
  late Animation<double> _bgFade;

  // Logo ring glow
  late AnimationController _glowCtrl;
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;

  // Logo pop-in
  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  // Pulse (idle loop)
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  // Text reveal
  late AnimationController _textCtrl;
  late Animation<double> _nameSlide;
  late Animation<double> _nameFade;
  late Animation<double> _taglineFade;

  static const _accent = Color(0xFFFF4D67);
  static const _bg = Color(0xFF0D0D0D);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _glowScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut),
    );
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut),
    );

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _nameSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _textCtrl,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _textCtrl,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _textCtrl,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _bgCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    _glowCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    _navigateToLogin();
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 700),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _glowCtrl.dispose();
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FadeTransition(
        opacity: _bgFade,
        child: Container(
          color: _bg,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo + glow ────────────────────────────────────────────
                AnimatedBuilder(
                  animation: Listenable.merge(
                      [_glowCtrl, _logoCtrl, _pulseCtrl]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulse.value,
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Soft radial glow behind logo
                            Transform.scale(
                              scale: _glowScale.value,
                              child: Opacity(
                                opacity: _glowOpacity.value * 0.35,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [_accent, Colors.transparent],
                                      stops: [0.0, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Logo
                            Transform.scale(
                              scale: _logoScale.value,
                              child: Opacity(
                                opacity: _logoFade.value,
                                child: Image.asset(
                                  'assets/images/charo_logo.png',
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.contain,
                                  color: _accent,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── App name ───────────────────────────────────────────────
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (context, child) =>Transform.translate(
                    offset: Offset(0, _nameSlide.value),
                    child: Opacity(
                      opacity: _nameFade.value,
                      child: Text(
                        'Charo',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Tagline ────────────────────────────────────────────────
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (context, child) =>Opacity(
                    opacity: _taglineFade.value,
                    child: Text(
                      'Swipe. Match. Connect.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

  late AnimationController _ringCtrl;
  late Animation<double> _ringScale;
  late Animation<double> _ringFade;

  late AnimationController _logoCtrl;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  late AnimationController _textCtrl;
  late Animation<double> _nameFade;
  late Animation<double> _nameSpacing;
  late Animation<double> _taglineFade;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  static const _bg = Color(0xFF0A0A0A);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ringScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );
    _ringFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _nameSpacing = Tween<double>(begin: 4.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _ringCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    _navigateToLogin();
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Concentric rings + C monogram ──────────────────────────
            AnimatedBuilder(
              animation: Listenable.merge([_ringCtrl, _logoCtrl, _pulseCtrl]),
              builder: (context, _) {
                return Transform.scale(
                  scale: _pulse.value,
                  child: Opacity(
                    opacity: _ringFade.value,
                    child: Transform.scale(
                      scale: _ringScale.value,
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ring
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF222222),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            // Middle ring
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF333333),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            // Inner ring
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF555555),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            // C monogram
                            Opacity(
                              opacity: _logoFade.value,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Text(
                                  'C',
                                  style: GoogleFonts.cormorantGaramond(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // ── CHARO wordmark ─────────────────────────────────────────
            AnimatedBuilder(
              animation: _textCtrl,
              builder: (context, _) {
                return Opacity(
                  opacity: _nameFade.value,
                  child: Text(
                    'CHARO',
                    style: GoogleFonts.raleway(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300, letterSpacing: _nameSpacing.value),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ── Tagline ────────────────────────────────────────────────
            AnimatedBuilder(
              animation: _textCtrl,
              builder: (context, _) {
                return Opacity(
                  opacity: _taglineFade.value,
                  child: Text(
                    'CONNECT · BELONG · LOVE',
                    style: GoogleFonts.raleway(color: const Color(0xFF333333), fontSize: 9, fontWeight: FontWeight.w400, letterSpacing: 3.0),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
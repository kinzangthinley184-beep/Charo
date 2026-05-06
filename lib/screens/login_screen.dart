import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../painters/cultural_border_painter.dart';
import '../widgets/phone_field.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  Country _country = kCountries.first;
  bool _loading = false;

  late AnimationController _enterCtrl;
  late Animation<double> _headerSlide;
  late Animation<double> _cardSlide;
  late Animation<double> _fadeFull;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _headerSlide = Tween<double>(begin: -40.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _enterCtrl,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _cardSlide = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _enterCtrl,
          curve: const Interval(0.2, 0.9, curve: Curves.easeOut)),
    );
    _fadeFull = CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut));

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) =>
            OtpScreen(phoneNumber: '${_country.dialCode} ${_phoneCtrl.text}'),
        transitionsBuilder: (_, animation, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: _enterCtrl,
        builder: (_, _) => FadeTransition(
          opacity: _fadeFull,
          child: CustomPaint(
            painter: const CulturalBorderPainter(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Transform.translate(
                      offset: Offset(0, _headerSlide.value),
                      child: _Header(screenWidth: size.width),
                    ),
                    Transform.translate(
                      offset: Offset(0, _cardSlide.value),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        child: _LoginCard(
                          formKey: _formKey,
                          phoneCtrl: _phoneCtrl,
                          loading: _loading,
                          onContinue: _onContinue,
                          onCountryChanged: (c) => _country = c,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final double screenWidth;
  const _Header({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              child: CustomPaint(painter: _HeaderArcPainter()),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                28, MediaQuery.of(context).padding.top + 24, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.35)),
                      ),
                      child: Center(
                        child: Text('C',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold)),
                      ),
                    ),
                    const Spacer(),
                    _BhutanBadge(),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Welcome\nto Charo',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cream,
                        height: 1.15)),
                const SizedBox(height: 12),
                Text('Sign in to access your account',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.cream.withValues(alpha: 0.65),
                        letterSpacing: 0.2)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                        width: 40, height: 2,
                        decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(1))),
                    const SizedBox(width: 6),
                    Container(
                        width: 8, height: 2,
                        color: AppColors.gold.withValues(alpha: 0.4)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BhutanBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇧🇹', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('Bhutan',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}

class _HeaderArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60;

    canvas.drawCircle(
        Offset(size.width * 1.1, size.height * 0.2), size.width * 0.8, paint);
    canvas.drawCircle(
        Offset(-size.width * 0.1, size.height * 1.1), size.width * 0.7, paint);

    final dotPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
          Offset(size.width * 0.82 + i * 6, 60), 2.0 - i * 0.3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Login card ─────────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final bool loading;
  final VoidCallback onContinue;
  final ValueChanged<Country> onCountryChanged;

  const _LoginCard({
    required this.formKey,
    required this.phoneCtrl,
    required this.loading,
    required this.onContinue,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone Number',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextSecondary,
                    letterSpacing: 0.5)),
            const SizedBox(height: 10),

            PhoneInputField(
              controller: phoneCtrl,
              onCountryChanged: onCountryChanged,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (v.trim().length < 6) return 'Enter a valid phone number';
                return null;
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 13,
                    color: AppColors.darkTextSecondary.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text("We'll send a 6-digit OTP to verify your number",
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.darkTextSecondary
                            .withValues(alpha: 0.7))),
              ],
            ),

            const SizedBox(height: 28),

            _GradientButton(loading: loading, onTap: onContinue, label: 'Continue'),

            const SizedBox(height: 24),

            Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  color: AppColors.darkTextSecondary.withValues(alpha: 0.55),
                  height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;
  final String label;

  const _GradientButton(
      {required this.loading, required this.onTap, required this.label});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.loading
                ? LinearGradient(colors: [
                    AppColors.saffron.withValues(alpha: 0.5),
                    AppColors.saffron.withValues(alpha: 0.5)
                  ])
                : AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.loading
                ? []
                : [
                    BoxShadow(
                        color: AppColors.saffron.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6))
                  ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation(Colors.white)))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.label,
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../core/app_colors.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpCtrl = TextEditingController();
  final StreamController<ErrorAnimationType> _errorCtrl =
      StreamController<ErrorAnimationType>();

  bool _loading = false;
  bool _hasError = false;
  int _secondsLeft = 60;
  Timer? _timer;

  late AnimationController _enterCtrl;
  late Animation<double> _slideIn;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideIn = Tween<double>(begin: 40.0, end: 0.0)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    _fadeIn =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterCtrl.forward();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onCompleted(String code) {
    if (code.length == 6) _verifyOtp(code);
  }

  Future<void> _verifyOtp(String code) async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    if (code == '000000') {
      setState(() {
        _loading = false;
        _hasError = true;
      });
      _errorCtrl.add(ErrorAnimationType.shake);
    } else {
      setState(() => _loading = false);
      _showSuccess();
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(phoneNumber: widget.phoneNumber),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _errorCtrl.close();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 18, color: AppColors.darkTextPrimary),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: AnimatedBuilder(
        animation: _enterCtrl,
        builder: (_, _) => FadeTransition(
          opacity: _fadeIn,
          child: Transform.translate(
            offset: Offset(0, _slideIn.value),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.headerGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.saffron.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 26),
                  ),

                  const SizedBox(height: 24),

                  Text('Verify your\nnumber',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextPrimary,
                          height: 1.2)),

                  const SizedBox(height: 12),

                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.darkTextSecondary,
                          height: 1.5),
                      children: [
                        const TextSpan(
                            text: 'Enter the 6-digit code sent to\n'),
                        TextSpan(
                          text: widget.phoneNumber,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.saffron),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpCtrl,
                    errorAnimationController: _errorCtrl,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.scale,
                    autoFocus: true,
                    onCompleted: _onCompleted,
                    onChanged: (_) {
                      if (_hasError) setState(() => _hasError = false);
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(14),
                      fieldHeight: 60,
                      fieldWidth: 50,
                      activeFillColor: AppColors.darkElevated,
                      inactiveFillColor: AppColors.darkSurface,
                      selectedFillColor: AppColors.darkElevated,
                      activeColor: AppColors.saffron,
                      inactiveColor: AppColors.darkBorder,
                      selectedColor: AppColors.gold,
                      errorBorderColor: Colors.red.shade400,
                    ),
                    enableActiveFill: true,
                    textStyle: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary),
                    boxShadows: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _hasError
                        ? Padding(
                            key: const ValueKey('err'),
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    size: 14, color: Colors.red.shade400),
                                const SizedBox(width: 6),
                                Text('Incorrect code. Please try again.',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.red.shade400)),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('no-err')),
                  ),

                  const SizedBox(height: 32),

                  _VerifyButton(
                    loading: _loading,
                    onTap: () {
                      if (_otpCtrl.text.length == 6) {
                        _verifyOtp(_otpCtrl.text);
                      }
                    },
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: _secondsLeft > 0
                        ? RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.darkTextSecondary),
                              children: [
                                const TextSpan(text: 'Resend code in '),
                                TextSpan(
                                  text: '${_secondsLeft}s',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.saffron),
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              _otpCtrl.clear();
                              _startTimer();
                            },
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.darkTextSecondary),
                                children: [
                                  const TextSpan(
                                      text: "Didn't receive it? "),
                                  TextSpan(
                                    text: 'Resend OTP',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.saffron,
                                        decoration:
                                            TextDecoration.underline,
                                        decorationColor: AppColors.saffron),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_rounded,
                            size: 22,
                            color: AppColors.gold.withValues(alpha: 0.8)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your data is protected with end-to-end encryption',
                            style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: AppColors.darkTextSecondary,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Verify button ──────────────────────────────────────────────────────────────

class _VerifyButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _VerifyButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: loading ? null : AppColors.buttonGradient,
          color: loading
              ? AppColors.saffron.withValues(alpha: 0.4)
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: loading
              ? []
              : [
                  BoxShadow(
                      color: AppColors.saffron.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6))
                ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white)))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Verify & Continue',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Success dialog ─────────────────────────────────────────────────────────────

class _SuccessDialog extends StatelessWidget {
  final String phoneNumber;
  const _SuccessDialog({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.saffron.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 40),
            ),

            const SizedBox(height: 24),

            Text('Verified!',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary)),

            const SizedBox(height: 8),

            Text('$phoneNumber\nhas been verified successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.darkTextSecondary,
                    height: 1.6)),

            const SizedBox(height: 8),

            Text('འབྲུག་ཡུལ།',
                style: TextStyle(
                    fontSize: 20,
                    color: AppColors.gold.withValues(alpha: 0.7))),

            const SizedBox(height: 28),

            GestureDetector(
              onTap: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              ),
              child: Container(
                width: double.infinity, height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text('Enter Charo',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

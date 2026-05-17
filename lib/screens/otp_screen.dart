import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/app_state.dart';
import 'home_screen.dart';

// Design-system tokens — matches login_screen / splash_screen
const _bg     = Color(0xFF0D0D0D);
const _card   = Color(0xFF1A1A1A);
const _accent = Color(0xFFFF4D67);
const _gray   = Color(0xFF8E8E93);
const _input  = Color(0xFF242424);
const _border = Color(0xFF3A3A3A);

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
  final PhoneAuthCredential? autoCredential;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
    this.autoCredential,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpCtrl = PinInputController();

  bool _loading = false;
  bool _hasError = false;
  int _secondsLeft = 60;
  Timer? _timer;

  late String _verificationId;
  int? _resendToken;

  late AnimationController _enterCtrl;
  late Animation<double> _slideIn;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _startTimer();

    if (widget.autoCredential != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _signInWithCredential(widget.autoCredential!);
      });
    }

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideIn = Tween<double>(begin: 40.0, end: 0.0)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    _fadeIn = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
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
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: code,
    );
    await _signInWithCredential(credential);
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user;
      if (!mounted) return;
      await context.read<AppState>().setAuthenticated(
            user!.uid,
            user.phoneNumber ?? widget.phoneNumber,
          );
      setState(() => _loading = false);
      _showSuccess();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
      _otpCtrl.triggerError();
      final msg = e.code == 'invalid-verification-code'
          ? 'Incorrect code. Please try again.'
          : (e.message ?? 'Verification failed.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
      _otpCtrl.triggerError();
    }
  }

  Future<void> _resendCode() async {
    _otpCtrl.clear();
    _startTimer();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      forceResendingToken: _resendToken,
      verificationCompleted: (credential) => _signInWithCredential(credential),
      verificationFailed: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Failed to resend code.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      },
      codeSent: (verificationId, resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
        });
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
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
    _otpCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _input,
              shape: BoxShape.circle,
              border: Border.all(color: _border),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 18, color: Colors.white),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: AnimatedBuilder(
        animation: _enterCtrl,
        builder: (context, child) => FadeTransition(
          opacity: _fadeIn,
          child: Transform.translate(
            offset: Offset(0, _slideIn.value),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Lock icon ──────────────────────────────────────────────
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: _accent.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: _accent, size: 26),
                  ),

                  const SizedBox(height: 24),

                  // ── Heading ────────────────────────────────────────────────
                  Text(
                    'Verify your\nnumber',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: _gray, height: 1.5),
                      children: [
                        const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                        TextSpan(
                          text: widget.phoneNumber,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, color: _accent),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── PIN field ──────────────────────────────────────────────
                  MaterialPinField(
                    length: 6,
                    pinController: _otpCtrl,
                    keyboardType: TextInputType.number,
                    autoFocus: true,
                    onCompleted: _onCompleted,
                    onChanged: (_) {
                      if (_hasError) setState(() => _hasError = false);
                    },
                    theme: MaterialPinTheme(
                      shape: MaterialPinShape.outlined,
                      borderRadius: BorderRadius.circular(14),
                      cellSize: const Size(50, 60),
                      fillColor: _card,
                      focusedFillColor: _input,
                      filledFillColor: _input,
                      borderColor: _border,
                      focusedBorderColor: _accent,
                      filledBorderColor: _accent,
                      errorBorderColor: Colors.red.shade400,
                      textStyle: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      boxShadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),

                  // ── Inline error ───────────────────────────────────────────
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
                                Text(
                                  'Incorrect code. Please try again.',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.red.shade400),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('no-err')),
                  ),

                  const SizedBox(height: 32),

                  // ── Verify button ──────────────────────────────────────────
                  _VerifyButton(
                    loading: _loading,
                    onTap: () {
                      if (_otpCtrl.text.length == 6) {
                        _verifyOtp(_otpCtrl.text);
                      }
                    },
                  ),

                  const SizedBox(height: 28),

                  // ── Resend row ─────────────────────────────────────────────
                  Center(
                    child: _secondsLeft > 0
                        ? RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: _gray),
                              children: [
                                const TextSpan(text: 'Resend code in '),
                                TextSpan(
                                  text: '${_secondsLeft}s',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: _accent),
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: _resendCode,
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: _gray),
                                children: [
                                  const TextSpan(text: "Didn't receive it? "),
                                  TextSpan(
                                    text: 'Resend OTP',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: _accent,
                                      decoration: TextDecoration.underline,
                                      decorationColor: _accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // ── Security notice ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_rounded,
                            size: 22,
                            color: _accent.withValues(alpha: 0.8)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your data is protected with end-to-end encryption',
                            style: GoogleFonts.poppins(
                                fontSize: 11.5, color: _gray, height: 1.5),
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

// ── Verify button — pill style matching login_screen ──────────────────────────

class _VerifyButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;

  const _VerifyButton({required this.loading, required this.onTap});

  @override
  State<_VerifyButton> createState() => _VerifyButtonState();
}

class _VerifyButtonState extends State<_VerifyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.loading ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.loading
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.loading
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: Colors.black, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Verify & Continue',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
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

// ── Success dialog ─────────────────────────────────────────────────────────────

class _SuccessDialog extends StatelessWidget {
  final String phoneNumber;
  const _SuccessDialog({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 40),
            ),

            const SizedBox(height: 24),

            Text(
              'Verified!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '$phoneNumber\nhas been verified successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: _gray, height: 1.6),
            ),

            const SizedBox(height: 28),

            GestureDetector(
              onTap: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              ),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'Enter Charo',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

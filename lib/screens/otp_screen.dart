import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/app_state.dart';
import 'home_screen.dart';

const _bg       = Color(0xFF0A0A0A);
const _field    = Color(0xFF141414);
const _border   = Color(0xFF333333);
const _labelClr = Color(0xFF555555);
const _subClr   = Color(0xFF666666);

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

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrs =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes =
      List.generate(6, (_) => FocusNode());

  bool _loading  = false;
  bool _hasError = false;
  int  _secondsLeft = 60;
  Timer? _timer;

  late String _verificationId;
  int? _resendToken;

  String get _otp => _ctrs.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken    = widget.resendToken;
    _startTimer();

    if (widget.autoCredential != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _signInWithCredential(widget.autoCredential!);
      });
    }
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

  Future<void> _verifyOtp(String code) async {
    if (code.length != 6) return;
    setState(() {
      _loading  = true;
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
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final user   = result.user;
      if (!mounted) return;
      await context.read<AppState>().setAuthenticated(
            user!.uid,
            user.phoneNumber ?? widget.phoneNumber,
          );
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading  = false;
        _hasError = true;
      });
      _snack(e.code == 'invalid-verification-code'
          ? 'Incorrect code. Please try again.'
          : (e.message ?? 'Verification failed.'));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading  = false;
        _hasError = true;
      });
    }
  }

  Future<void> _resendCode() async {
    for (final c in _ctrs) { c.clear(); }
    setState(() => _hasError = false);
    _nodes.first.requestFocus();
    _startTimer();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      forceResendingToken: _resendToken,
      verificationCompleted: (credential) => _signInWithCredential(credential),
      verificationFailed: (e) {
        if (!mounted) return;
        _snack(e.message ?? 'Failed to resend code.');
      },
      codeSent: (verificationId, resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _resendToken    = resendToken;
        });
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
      backgroundColor: const Color(0xFF1A1A1A),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrs) { c.dispose(); }
    for (final f in _nodes) { f.dispose(); }
    super.dispose();
  }

  // ── OTP box ─────────────────────────────────────────────────────────────────

  Widget _box(int i) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _ctrs[i].text.isEmpty &&
            i > 0) {
          _ctrs[i - 1].clear();
          _nodes[i - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        width: 44,
        height: 52,
        child: TextField(
          controller: _ctrs[i],
          focusNode: _nodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          cursorColor: Colors.white,
          onChanged: (value) {
            if (_hasError) setState(() => _hasError = false);
            if (value.isNotEmpty) {
              if (i < 5) {
                _nodes[i + 1].requestFocus();
              } else {
                _nodes[i].unfocus();
                _verifyOtp(_otp);
              }
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: _field,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _border, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _hasError ? _subClr : _border,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _hasError ? _subClr : Colors.white,
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimer() {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(28, topPad + 64, 28, bottomPad + 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section label ───────────────────────────────────────────────
            const Text(
              'VERIFICATION CODE',
              style: TextStyle(fontSize: 10, letterSpacing: 2, color: _labelClr),
            ),

            const SizedBox(height: 20),

            // ── Headline ────────────────────────────────────────────────────
            const Text(
              'Enter the\ncode',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: _subClr),
                children: [
                  const TextSpan(text: 'Sent to '),
                  TextSpan(
                    text: widget.phoneNumber,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 44),

            // ── OTP boxes ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, _box),
            ),

            // Inline error
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _hasError
                  ? const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Incorrect code. Please try again.',
                        style: TextStyle(fontSize: 12, color: _subClr),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 36),

            // ── Verify button ───────────────────────────────────────────────
            _PrimaryButton(
              label: 'VERIFY CODE',
              loading: _loading,
              onTap: () => _verifyOtp(_otp),
            ),

            const SizedBox(height: 32),

            // ── Resend row ──────────────────────────────────────────────────
            Center(
              child: _secondsLeft > 0
                  ? Text(
                      'Resend in ${_formatTimer()}',
                      style: const TextStyle(fontSize: 13, color: _subClr),
                    )
                  : GestureDetector(
                      onTap: _resendCode,
                      child: const Text(
                        'Resend code',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // ── Change number ───────────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  '← Change number',
                  style: TextStyle(fontSize: 13, color: _labelClr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Primary button ─────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/phone_field.dart';
import 'otp_screen.dart';

const _bg       = Color(0xFF0A0A0A);
const _field    = Color(0xFF141414);
const _border   = Color(0xFF333333);
const _labelClr = Color(0xFF555555);
const _subClr   = Color(0xFF666666);
const _dimClr   = Color(0xFF444444);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final Country _country = kCountries.first;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    final phoneNumber = '${_country.dialCode}${_phoneCtrl.text.trim()}';
    setState(() => _loading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (!mounted) return;
          Navigator.of(context).push(_slideRoute(OtpScreen(
            phoneNumber: phoneNumber,
            verificationId: '',
            autoCredential: credential,
          )));
        } catch (_) {}
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        setState(() => _loading = false);
        _snack(e.message ?? 'Verification failed. Check your number.');
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.of(context).push(_slideRoute(OtpScreen(
          phoneNumber: phoneNumber,
          verificationId: verificationId,
          resendToken: resendToken,
        )));
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

  PageRouteBuilder<void> _slideRoute(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondary) => page,
        transitionsBuilder: (context, animation, secondary, child) =>
            SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(28, topPad + 64, 28, bottomPad + 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ───────────────────────────────────────────────────────
              Text(
                'CHARO',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'CONNECT · BELONG · LOVE',
                style: TextStyle(fontSize: 10, color: _dimClr, letterSpacing: 3),
              ),

              const SizedBox(height: 72),

              // ── Headline ────────────────────────────────────────────────────
              const Text(
                'Enter your\nnumber',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We'll send a one-time verification code.",
                style: TextStyle(fontSize: 13, color: _subClr),
              ),

              const SizedBox(height: 40),

              // ── Phone label ─────────────────────────────────────────────────
              const Text(
                'PHONE NUMBER',
                style: TextStyle(fontSize: 10, letterSpacing: 2, color: _labelClr),
              ),
              const SizedBox(height: 10),

              // ── Phone row ───────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country chip (+975, Bhutan only)
                  Container(
                    width: 72,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _field,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border, width: 0.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _country.dialCode,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Number field
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      cursorColor: Colors.white,
                      decoration: _inputDeco('Phone number'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (v.trim().length < 6) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Button ──────────────────────────────────────────────────────
              _PrimaryButton(
                label: 'CONTINUE',
                loading: _loading,
                onTap: _onContinue,
              ),

              const SizedBox(height: 40),

              // ── Terms ───────────────────────────────────────────────────────
              const Center(
                child: Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _labelClr, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

InputDecoration _inputDeco(String hint) => InputDecoration(
      filled: true,
      fillColor: _field,
      hintText: hint,
      hintStyle: const TextStyle(color: _dimClr, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 0.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _subClr, width: 0.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _subClr, width: 0.5),
      ),
      errorStyle: const TextStyle(color: _subClr, fontSize: 11),
    );

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

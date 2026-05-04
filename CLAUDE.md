# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # install dependencies
flutter analyze          # lint / static analysis (must pass with 0 issues)
flutter test             # run unit/widget tests
flutter run              # run on connected device or emulator
flutter build apk        # build Android APK
```

## Architecture

```
lib/
├── main.dart                         # Entry point → CharoApp → SplashScreen
├── core/
│   ├── app_colors.dart               # All color constants + gradient presets
│   └── app_theme.dart                # ThemeData (Poppins + Playfair Display)
├── painters/
│   ├── dragon_circle_painter.dart    # Animated Thunder Dragon (CustomPainter, progress 0→1)
│   └── cultural_border_painter.dart  # Bhutanese corner knot pattern for login background
├── screens/
│   ├── splash_screen.dart            # Full-screen animated splash (3-step AnimationController)
│   ├── login_screen.dart             # Phone number login with Bhutan (+975) pre-selected
│   └── otp_screen.dart               # 6-digit OTP verification + 60s resend timer
└── widgets/
    └── phone_field.dart              # PhoneInputField: country picker + digit-only text field
```

## Key design decisions

- **Bhutanese palette**: `AppColors.crimson` / `saffron` / `gold` — never use raw `Color(...)` values in widgets, always reference `AppColors`.
- **Dragon animation**: `DragonCirclePainter` accepts `progress` (0.0–1.0). It uses `PathMetrics.extractPath` to animate the body drawing itself, then the head, claws, and jewel appear in sequence.  
- **Phone field**: `kCountries` list in `phone_field.dart` — Bhutan `+975` is index 0 (default). `maxDigits` drives both the hint mask and `LengthLimitingTextInputFormatter`.
- **OTP demo**: any 6-digit code except `000000` passes. Replace `_verifyOtp` with real Firebase/SMS logic.
- **Fonts**: `google_fonts` (Playfair Display for headings, Poppins for body). No bundled font assets needed.
- **Deprecations**: use `.withValues(alpha: x)` not `.withOpacity(x)`; use single `_` wildcard for ignored callback params.

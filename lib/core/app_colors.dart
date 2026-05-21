import 'package:flutter/material.dart';

/// Central color palette for Charo — Saffron & Orange-Red Bhutanese theme.
/// Always reference these constants; never use raw Color() values in widgets.
class AppColors {
  // ── Primary brand — Saffron tones ─────────────────────────────────────────
  /// Vibrant saffron — primary brand color, buttons, active states.
  static const Color saffron = Color(0xFFFF9933);
  /// Darker saffron used in dragon artwork and secondary gradients.
  static const Color saffronDark = Color(0xFFE8600C);
  /// Deep saffron used for dark gradient backgrounds (splash, header).
  static const Color saffronDeep = Color(0xFF5C3000);

  // ── Secondary accent — Orange-Red ─────────────────────────────────────────
  /// Orange-Red used as gradient endpoint on buttons and action elements.
  static const Color orangeRed = Color(0xFFFF4500);
  static const Color orangeRedDark = Color(0xFFCC3700);

  // ── Gold (Bhutanese ceremonial accent) ────────────────────────────────────
  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFF5C842);
  static const Color goldDark = Color(0xFF9A7010);
  /// Bright gold used in jewel / chakra artwork.
  static const Color goldBright = Color(0xFFFFD700);

  // ── Neutral tones ─────────────────────────────────────────────────────────
  static const Color cream = Color(0xFFFDF6E3);
  static const Color offWhite = Color(0xFFF7F0E8);

  // ── Dark theme surfaces ───────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF1A1410);
  static const Color darkSurface = Color(0xFF221C16);
  static const Color darkElevated = Color(0xFF2A2218);
  static const Color darkCard = Color(0xFF251E18);
  static const Color darkBorder = Color(0xFF3A3028);
  static const Color darkDivider = Color(0xFF2E2620);

  // ── Dark theme text ───────────────────────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFF2F2F2);
  static const Color darkTextSecondary = Color(0xFF888888);
  static const Color darkTextMuted = Color(0xFF555555);

  // ── Feature / action colors ───────────────────────────────────────────────
  static const Color premiumYellow = Color(0xFFFFCB30);
  static const Color premiumYellowDark = Color(0xFFE6A800);
  static const Color likeRed = Color(0xFFE8445A);
  static const Color likeGreen = Color(0xFF4CAF50);
  static const Color passGray = Color(0xFF6B6B6B);
  static const Color chatGray = Color(0xFF8A8A8A);
  static const Color superBlue = Color(0xFF1DA1F2);
  static const Color matchPink = Color(0xFFFF4E6A);
  static const Color navUnselected = Color(0xFF444444);
  static const Color nearbyTeal = Color(0xFF00BCD4);
  static const Color errorRed = Color(0xFFE53935);

  // ── Premium luxury dark design system ────────────────────────────────────
  static const Color bg          = Color(0xFF000000);
  static const Color surface1    = Color(0xFF111111);
  static const Color surface2    = Color(0xFF1A1A1A);
  static const Color white60     = Color(0x99FFFFFF);
  static const Color white30     = Color(0x4DFFFFFF);
  static const Color white20     = Color(0x33FFFFFF);
  static const Color white10     = Color(0x1AFFFFFF);
  static const Color borderSubtle = Color(0x0DFFFFFF); // 5% white
  static const Color borderThin   = Color(0x1AFFFFFF); // 10% white
  static const Color onlineGreen  = Color(0xFF22C55E);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [saffronDeep, saffronDark, saffron],
    stops: [0.0, 0.5, 1.0],
  );

  /// Primary CTA gradient — saffron fading to orange-red.
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [saffron, orangeRed],
  );

  /// Header section gradient (login, OTP screens).
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [saffronDeep, saffronDark],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkSurface, darkCard],
  );
}

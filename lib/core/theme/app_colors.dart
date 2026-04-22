import 'package:flutter/material.dart';

/// Canonical color palette extracted from all 26 design reference screens
/// in stitch_futuristic_video_call/. Every hex value is verified against
/// the Tailwind config blocks in the design HTML files.
class AppColors {
  AppColors._();

  // ─── Brand Colors ────────────────────────────────────────
  static const Color primary = Color(0xFF00FFFF);        // Neon Cyan — THE brand color
  static const Color primaryDim = Color(0xFF00CCCC);     // Dimmed cyan for gradients
  static const Color secondaryPink = Color(0xFFFF00FF);  // Neon Pink — badges, accents
  static const Color hotPink = Color(0xFFFF69B4);        // "Forgot Password" links
  static const Color accentPurple = Color(0xFFA855F7);   // Purple — gradient accents
  static const Color accentBlue = Color(0xFF3B82F6);     // Blue — FAB gradient

  // ─── Backgrounds ─────────────────────────────────────────
  static const Color background = Color(0xFF050A0A);     // Deepest dark (dashboard, chat)
  static const Color backgroundAlt = Color(0xFF0F2323);  // Slightly lighter (login, splash, settings)
  static const Color surfaceDark = Color(0xFF173636);    // Elevated surface

  // ─── Glassmorphism ───────────────────────────────────────
  static const Color glassSurface = Color(0x990F2323);   // rgba(15, 35, 35, 0.6)
  static const Color glassSurfaceLight = Color(0x66141E1E); // rgba(20, 30, 30, 0.4)
  static const Color glassBorder = Color(0x0DFFFFFF);    // rgba(255, 255, 255, 0.05)
  static const Color glassBorderCyan = Color(0x1A00FFFF); // rgba(0, 255, 255, 0.1)
  static const Color glassInputBg = Color(0x33000000);   // rgba(0, 0, 0, 0.2)
  static const Color glassInputBorder = Color(0x2600FFFF); // rgba(0, 255, 255, 0.15)
  static const Color glassNavBg = Color(0xD90A1414);     // rgba(10, 20, 20, 0.85)

  // ─── Text ────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);  // white/70
  static const Color textMuted = Color(0x66FFFFFF);      // white/40
  static const Color textDim = Color(0x33FFFFFF);        // white/20

  // ─── Status ──────────────────────────────────────────────
  static const Color online = Color(0xFF22C55E);         // green-500
  static const Color away = Color(0xFFEAB308);           // yellow-500
  static const Color danger = Color(0xFFFF0F5B);         // Delete/danger
  static const Color error = Color(0xFFEF4444);          // red-500 (call end)

  // ─── Utility ─────────────────────────────────────────────
  static const Color white5 = Color(0x0DFFFFFF);         // white/5
  static const Color white10 = Color(0x1AFFFFFF);        // white/10
  static const Color white20 = Color(0x33FFFFFF);        // white/20
  static const Color white50 = Color(0x80FFFFFF);        // white/50
  static const Color white80 = Color(0xCCFFFFFF);        // white/80
}

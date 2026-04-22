import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized decoration presets matching the glassmorphism, glow, and
/// gradient specs from the design reference HTML/CSS files.
class AppDecorations {
  AppDecorations._();

  // ─── Glass Panel ─────────────────────────────────────────
  /// Standard glassmorphism container (header bars, cards, overlays).
  /// Usage: wrap with ClipRRect + BackdropFilter, then apply this decoration.
  static BoxDecoration glassPanel({
    double borderRadius = 16,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: AppColors.glassSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.glassBorderCyan,
        width: 1,
      ),
    );
  }

  /// Lighter glass panel (chat bubbles, secondary surfaces).
  static BoxDecoration glassPanelLight({double borderRadius = 16}) {
    return BoxDecoration(
      color: AppColors.glassSurfaceLight,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.glassBorder, width: 1),
    );
  }

  /// Glass input field container.
  static BoxDecoration glassInput({bool focused = false}) {
    return BoxDecoration(
      color: AppColors.glassInputBg,
      borderRadius: BorderRadius.circular(9999),
      border: Border.all(
        color: focused ? AppColors.primary : AppColors.glassInputBorder,
        width: 1,
      ),
      boxShadow: focused
          ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 15)]
          : null,
    );
  }

  /// Glass navigation bar.
  static BoxDecoration glassNav() {
    return const BoxDecoration(
      color: AppColors.glassNavBg,
      border: Border(
        top: BorderSide(color: AppColors.glassBorderCyan, width: 1),
      ),
    );
  }

  /// Glass card with subtle gradient fill.
  static BoxDecoration glassCard({double borderRadius = 16}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment(-0.5, -0.5),
        end: Alignment(0.5, 0.5),
        colors: [Color(0x08FFFFFF), Color(0x03FFFFFF)],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.glassInputBorder, width: 1),
      boxShadow: const [
        BoxShadow(color: Color(0x1A000000), blurRadius: 30),
      ],
    );
  }

  // ─── Neon Shadows ────────────────────────────────────────
  static List<BoxShadow> get neonShadowPrimary => [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10),
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20),
  ];

  static List<BoxShadow> get neonShadowPink => [
    BoxShadow(color: AppColors.secondaryPink.withValues(alpha: 0.6), blurRadius: 8),
    BoxShadow(color: AppColors.secondaryPink.withValues(alpha: 0.3), blurRadius: 16),
  ];

  static List<BoxShadow> get neonShadowGreen => [
    BoxShadow(color: AppColors.online.withValues(alpha: 0.6), blurRadius: 8),
    BoxShadow(color: AppColors.online.withValues(alpha: 0.3), blurRadius: 12),
  ];

  static List<BoxShadow> get neonShadowDanger => [
    BoxShadow(color: AppColors.error.withValues(alpha: 0.6), blurRadius: 20),
  ];

  static List<BoxShadow> get neonShadowButton => [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 15),
  ];

  // ─── Gradients ───────────────────────────────────────────
  /// Primary button gradient (Sign Up, Log In, Send).
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [AppColors.primary, Color(0xFF0099FF)],
  );

  /// Sent message bubble gradient.
  static const LinearGradient sentMessageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDim],
  );

  /// FAB gradient (purple → blue).
  static const LinearGradient fabGradient = LinearGradient(
    colors: [AppColors.accentPurple, AppColors.accentBlue],
  );

  /// Avatar ring gradient (cyan → purple).
  static const LinearGradient avatarRingGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.primary, AppColors.accentPurple],
  );

  /// Avatar ring gradient (purple → pink).
  static const LinearGradient avatarRingPinkGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.accentPurple, AppColors.secondaryPink],
  );

  /// Video call vignette overlay.
  static const LinearGradient vignetteGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x99000000), Colors.transparent, Color(0xCC000000)],
    stops: [0.0, 0.4, 1.0],
  );

  // ─── Text Shadows ────────────────────────────────────────
  static List<Shadow> get textGlow => [
    Shadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10),
    Shadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20),
  ];

  static List<Shadow> get textGlowWhite => [
    Shadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 8),
  ];
}

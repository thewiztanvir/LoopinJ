import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/ambient_background.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/neon_button.dart';

/// Welcome splash screen matching `loopin_j_welcome_splash` design.
/// Features: animated "J" logo with breathing effect, circuit image,
/// glassmorphism button container, Sign Up / Login buttons.
class WelcomeSplashScreen extends StatelessWidget {
  const WelcomeSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground.standard(
        backgroundColor: AppColors.backgroundAlt,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // ─── Logo & Branding ─────────────────────
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated Logo "J"
                              _AnimatedLogo()
                                  .animate(onPlay: (c) => c.repeat())
                                  .custom(
                                    duration: 4000.ms,
                                    curve: Curves.easeInOut,
                                    builder: (context, value, child) {
                                      final scale = 1.0 + 0.02 * (0.5 - (value - 0.5).abs()) * 2;
                                      return Transform.scale(scale: scale, child: child);
                                    },
                                  ),
                              const SizedBox(height: 24),

                              // Title
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Loopin ',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    'J',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                              const SizedBox(height: 8),

                              // Subtitle
                              Text(
                                'CONNECT IN NEON',
                                style: TextStyle(
                                  color: AppColors.primary.withValues(alpha: 0.8),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 6,
                                  shadows: AppDecorations.textGlow,
                                ),
                              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                              const SizedBox(height: 24),

                              // Circuit Image Panel
                              GlassPanel(
                                borderRadius: 16,
                                child: SizedBox(
                                  height: 180,
                                  width: double.infinity,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Gradient overlay
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(alpha: 0.4),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Hub Icon + SECURE LINK
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.hub,
                                            color: AppColors.primary,
                                            size: 40,
                                          )
                                              .animate(onPlay: (c) => c.repeat())
                                              .fadeIn()
                                              .then()
                                              .custom(
                                                duration: 2000.ms,
                                                curve: Curves.easeInOut,
                                                builder: (context, value, child) {
                                                  final opacity = 0.6 + 0.4 * (0.5 - (value - 0.5).abs()) * 2;
                                                  return Opacity(opacity: opacity, child: child);
                                                },
                                              ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'SECURE LINK',
                                            style: TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(delay: 500.ms, duration: 800.ms).slideY(begin: 0.1),
                            ],
                          ),
                        ),

                        // ─── Action Buttons ──────────────────────
                        GlassPanel(
                          borderRadius: 40,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NeonButton(
                                text: 'Sign Up',
                                onPressed: () => context.push('/register'),
                              ),
                              const SizedBox(height: 16),
                              NeonButton(
                                text: 'Login',
                                isOutline: true,
                                onPressed: () => context.push('/login'),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'By joining, you agree to our ',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Open terms
                                    },
                                    child: Text(
                                      'Terms',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.15),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                ),
              ],
            ),
          ),
          // Top arc highlight
          Positioned(
            top: 0,
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
                boxShadow: AppDecorations.neonShadowPrimary,
              ),
            ),
          ),
          // "J" text
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, AppColors.primary],
            ).createShader(bounds),
            child: const Text(
              'J',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

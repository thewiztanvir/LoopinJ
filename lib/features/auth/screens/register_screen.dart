import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/ambient_background.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/glass_text_field.dart';
import '../../../shared/widgets/neon_button.dart';
import '../providers/auth_provider.dart';

/// Register screen styled to match the login design language.
/// Glass-panel card, pill-shaped inputs, gradient sign-up button.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _displayNameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (_, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (!state.isLoading && !state.hasError && state.hasValue) {
          context.go('/home');
        }
      },
    );

    return Scaffold(
      body: AmbientBackground.standard(
        backgroundColor: AppColors.backgroundAlt,
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.textSecondary),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ─── Branding ──────────────────
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  AppColors.accentPurple.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.accentPurple.withValues(alpha: 0.3),
                              ),
                              boxShadow: AppDecorations.neonShadowPink,
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1,
                              color: AppColors.secondaryPink,
                              size: 32,
                            ),
                          ).animate().fadeIn().scale(duration: 500.ms),
                          const SizedBox(height: 24),

                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Join ',
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                                TextSpan(
                                  text: 'LoopinJ',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 8),

                          const Text(
                            'Create your encrypted identity.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 32),

                          // ─── Glass Card ────────────────
                          GlassPanel(
                            borderRadius: 24,
                            blur: 20,
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                GlassTextField(
                                  controller: _displayNameController,
                                  label: 'Display Name',
                                  hintText: 'Choose a Neon ID',
                                  prefixIcon: Icons.badge,
                                  validator: (value) =>
                                      value!.isEmpty ? 'Enter display name' : null,
                                ),
                                const SizedBox(height: 20),

                                GlassTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  hintText: 'name@example.com',
                                  prefixIcon: Icons.mail,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) =>
                                      value!.isEmpty ? 'Enter email' : null,
                                ),
                                const SizedBox(height: 20),

                                GlassTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hintText: 'Min 6 characters',
                                  prefixIcon: Icons.lock,
                                  isPassword: true,
                                  validator: (value) =>
                                      value!.length < 6 ? 'Password too short' : null,
                                ),
                                const SizedBox(height: 32),

                                NeonButton(
                                  text: 'Sign Up',
                                  isLoading: authState.isLoading,
                                  onPressed: _handleRegister,
                                ),
                                const SizedBox(height: 16),

                                // E2EE note
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock,
                                        size: 12, color: AppColors.primary.withValues(alpha: 0.6)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'E2EE keys generated on sign-up',
                                      style: TextStyle(
                                        color: AppColors.primary.withValues(alpha: 0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.05),
                          const SizedBox(height: 32),

                          // ─── Footer ────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 600.ms),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

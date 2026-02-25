import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_text_field.dart';
import '../../../shared/widgets/neon_button.dart';
import '../providers/auth_provider.dart';

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
            SnackBar(content: Text(state.error.toString())),
          );
        } else if (!state.isLoading && !state.hasError && state.hasValue) {
          context.go('/home');
        }
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNeon),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=2564&auto=format&fit=crop'), // Abstract futuristic background
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            shadows: [
                              Shadow(color: AppColors.secondaryNeon, blurRadius: 10),
                            ],
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fade().scale(),
                    const SizedBox(height: 10),
                    Text(
                      'Join the immersive loop',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ).animate().fade().slideY(),
                    const SizedBox(height: 50),
                    GlassTextField(
                      controller: _displayNameController,
                      hintText: 'Display Name (Neon ID)',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value!.isEmpty ? 'Enter display name' : null,
                    ).animate().fade().slideX(),
                    const SizedBox(height: 20),
                    GlassTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      validator: (value) => value!.isEmpty ? 'Enter email' : null,
                    ).animate().fade().slideX(),
                    const SizedBox(height: 20),
                    GlassTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) => value!.length < 6 ? 'Password too short' : null,
                    ).animate().fade().slideX(),
                    const SizedBox(height: 40),
                    NeonButton(
                      text: 'SIGN UP & GENERATE E2EE KEYS',
                      isLoading: authState.isLoading,
                      onPressed: _handleRegister,
                    ).animate().fade().slideY(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_text_field.dart';
import '../../../shared/widgets/neon_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop'), // Abstract dark background placeholder
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
                      'Welcome to LoopinJ',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            shadows: [
                              Shadow(
                                color: AppColors.primaryNeon,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fade().scale(),
                    const SizedBox(height: 10),
                    Text(
                      'Secure & immersive communication',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ).animate().fade().slideY(),
                    const SizedBox(height: 50),
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
                      validator: (value) => value!.isEmpty ? 'Enter password' : null,
                    ).animate().fade().slideX(),
                    const SizedBox(height: 40),
                    NeonButton(
                      text: 'LOGIN',
                      isLoading: authState.isLoading,
                      onPressed: _handleLogin,
                    ).animate().fade().slideY(),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(
                        'Don\'t have an account? Sign up',
                        style: TextStyle(color: AppColors.primaryNeon),
                      ),
                    ).animate().fade(),
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

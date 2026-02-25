import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../../shared/widgets/glass_text_field.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Assuming currentUserModelProvider is populated
    ref.read(currentUserModelProvider.future).then((user) {
      if (user != null && mounted) {
        _displayNameController.text = user.displayName;
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Neon Preferences', style: TextStyle(color: AppColors.secondaryNeon)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryNeon),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: userAsync.when(
          data: (user) {
            if (user == null) return const Center(child: Text('Error loading profile'));
            
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.glassmorphismBackground,
                          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                          child: user.photoUrl == null ? Icon(Icons.person, size: 50, color: AppColors.secondaryNeon) : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                          child: Icon(Icons.edit, color: AppColors.secondaryNeon, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GlassTextField(
                      controller: _displayNameController,
                      hintText: 'Display Name',
                      prefixIcon: Icons.badge,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.glassmorphismBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassmorphismBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('E2EE Identity Key', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text(
                            user.publicKey,
                            style: const TextStyle(color: AppColors.primaryNeon, fontSize: 10, fontFamily: 'monospace'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    NeonButton(
                      text: 'SAVE CHANGES',
                      onPressed: () {
                        // TODO: Implement update display name in Firestore
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated!')));
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondaryNeon)),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

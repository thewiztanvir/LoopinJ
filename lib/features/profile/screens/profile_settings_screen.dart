import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../auth/providers/auth_provider.dart';

/// Account settings screen matching `loopin_j_account_settings` design.
/// Features: cyber gradient bg, avatar with gradient ring + edit button,
/// profile info section, security menu items, danger delete button.
class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _displayNameController = TextEditingController(text: '');

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -0.7),
            radius: 1.5,
            colors: [
              Color(0xFF1E1035), // purple tint
              Color(0xFF0F2323), // teal dark
              Color(0xFF050A0A), // deep black
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Ambient lights
            Positioned(
              top: -60,
              left: -80,
              child: IgnorePointer(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x339C27B0).withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: -60,
              child: IgnorePointer(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 80,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Content ───────────────────────────
            Column(
              children: [
                // Top bar
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: AppColors.white80, size: 22),
                          onPressed: () => context.pop(),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Account Settings',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance for back button
                      ],
                    ),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 24),

                      // ─── Avatar ────────────────────
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppDecorations.avatarRingGradient,
                                boxShadow: AppDecorations.neonShadowPrimary,
                              ),
                              padding: const EdgeInsets.all(3),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.backgroundAlt,
                                ),
                                padding: const EdgeInsets.all(2),
                                child: ClipOval(
                                  child: Container(
                                    color: AppColors.surfaceDark,
                                    child: const Icon(Icons.person,
                                        color: AppColors.primary, size: 40),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.background,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Icon(Icons.edit,
                                    color: AppColors.primary, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Username
                      userAsync.when(
                        data: (user) {
                          if (user != null && _displayNameController.text.isEmpty) {
                            _displayNameController.text = user.displayName;
                          }
                          return Center(
                            child: Text(
                              '@${user?.displayName.toLowerCase().replaceAll(' ', '_') ?? 'user'}',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (e, s) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 32),

                      // ─── Profile Information ───────
                      _SectionHeader(title: 'Profile Information'),
                      const SizedBox(height: 12),

                      GlassPanel(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DISPLAY NAME',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.glassInputBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.glassInputBorder,
                                ),
                              ),
                              child: TextField(
                                controller: _displayNameController,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.badge,
                                      color: AppColors.primary, size: 20),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            NeonButton(
                              text: 'Save Changes',
                              icon: Icons.save,
                              onPressed: () {
                                // TODO: Update display name
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Changes saved'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ─── Security & Privacy ────────
                      _SectionHeader(title: 'Security & Privacy'),
                      const SizedBox(height: 12),

                      GlassPanel(
                        borderRadius: 16,
                        child: Column(
                          children: [
                            _SettingsMenuItem(
                              icon: Icons.mail,
                              title: 'Update Email',
                              subtitle: 'user@loopin.com',
                              onTap: () {},
                            ),
                            Divider(color: AppColors.white5, height: 1),
                            _SettingsMenuItem(
                              icon: Icons.lock_reset,
                              title: 'Change Password',
                              subtitle: 'Last changed 3mo ago',
                              onTap: () {},
                            ),
                            Divider(color: AppColors.white5, height: 1),
                            _SettingsMenuItem(
                              icon: Icons.security,
                              title: 'Privacy Settings',
                              subtitle: 'Manage data & visibility',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ─── Danger Zone ───────────────
                      GestureDetector(
                        onTap: () {
                          // TODO: Delete account confirmation dialog
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9999),
                            color: AppColors.danger.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.3),
                            ),
                            boxShadow: AppDecorations.neonShadowDanger,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning,
                                  color: AppColors.danger, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Delete Account',
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This action is permanent and cannot be undone.\nAll your messages will be lost.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white20,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ─── Sign Out ──────────────────
                      GestureDetector(
                        onTap: () async {
                          await ref.read(authControllerProvider.notifier).signOut();
                          if (context.mounted) context.go('/');
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: AppColors.white20),
                          ),
                          child: const Center(
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.primary.withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ─── Settings Menu Item ────────────────────────────────────
class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(Icons.chevron_right,
                color: AppColors.white20, size: 22),
          ],
        ),
      ),
    );
  }
}

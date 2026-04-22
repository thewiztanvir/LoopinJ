import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/ambient_background.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/glass_nav_bar.dart';
import '../../../shared/widgets/neon_avatar.dart';

/// Find connections screen matching `find_neon_connections` design.
/// Features: glass header with search, pending requests section,
/// suggested users grid with glass cards, bottom nav.
class FindConnectionsScreen extends ConsumerStatefulWidget {
  const FindConnectionsScreen({super.key});

  @override
  ConsumerState<FindConnectionsScreen> createState() =>
      _FindConnectionsScreenState();
}

class _FindConnectionsScreenState extends ConsumerState<FindConnectionsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground.standard(
        child: Stack(
          children: [
            Column(
              children: [
                // ─── Header ──────────────────────────
                _SearchHeader(
                  controller: _searchController,
                  onBack: () => context.pop(),
                ),

                // ─── Content ─────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 100,
                    ),
                    children: [
                      // Pending Requests
                      _PendingRequestsSection(),
                      const SizedBox(height: 32),

                      // Suggested for You
                      _SuggestedSection(),
                    ],
                  ),
                ),
              ],
            ),

            // ─── Bottom Nav ──────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassNavBar(
                currentIndex: 1,
                onTap: (index) {
                  if (index == 0) context.go('/home');
                  if (index == 3) context.push('/profile-settings');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Header ─────────────────────────────────────────
class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBack;

  const _SearchHeader({required this.controller, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassSurfaceLight,
            border: Border(
              bottom: BorderSide(color: AppColors.white5),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: AppColors.textSecondary, size: 28),
                        onPressed: onBack,
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Loopin J',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      // Notification bell with dot
                      Stack(
                        children: [
                          const Icon(Icons.notifications,
                              color: AppColors.textSecondary, size: 24),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.6),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search bar
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search username or tag...',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const Icon(Icons.tune,
                            color: AppColors.textMuted, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pending Requests ──────────────────────────────────────
class _PendingRequestsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Pending Requests',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.2),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Requests card
        GlassPanel(
          borderRadius: 16,
          child: Column(
            children: [
              _RequestItem(
                name: 'Cyber_Kate',
                subtitle: 'Mutual: GlitchWizard',
                isOnline: true,
              ),
              Divider(color: AppColors.white5, height: 1),
              _RequestItem(
                name: 'Neo_John',
                subtitle: 'Sent you a request',
                isOnline: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestItem extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool isOnline;

  const _RequestItem({
    required this.name,
    required this.subtitle,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          NeonAvatar(
            size: 48,
            showOnlineIndicator: isOnline,
            showRing: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

          // Reject
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white5,
              ),
              child: const Icon(Icons.close,
                  color: AppColors.textMuted, size: 18),
            ),
          ),
          const SizedBox(width: 8),

          // Accept
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.check,
                  color: AppColors.primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Suggested Users ───────────────────────────────────────
class _SuggestedSection extends StatelessWidget {
  static const _users = [
    _SuggestedUser('GlitchWizard', 'Dev', 'Digital nomad wandering the net.', true),
    _SuggestedUser('Future_Fox', 'Artist', 'Creating neon dreams in VR.', false),
    _SuggestedUser('Aura_L', 'Music', 'Synthwave producer & DJ.', false),
    _SuggestedUser('Byte_Me', 'Gamer', 'Competitive FPS player.', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Suggested for You',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Icon(Icons.filter_list,
                  color: AppColors.textMuted, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...List.generate(_users.length, (i) {
          final user = _users[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SuggestedCard(user: user, isFilled: i == 0),
          );
        }),
      ],
    );
  }
}

class _SuggestedUser {
  final String name;
  final String tag;
  final String bio;
  final bool isFirstCard;
  const _SuggestedUser(this.name, this.tag, this.bio, this.isFirstCard);
}

class _SuggestedCard extends StatelessWidget {
  final _SuggestedUser user;
  final bool isFilled;

  const _SuggestedCard({required this.user, this.isFilled = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.glassCard(borderRadius: 16),
          child: Row(
            children: [
              NeonAvatar(
                size: 56,
                showRing: true,
                ringGradient: isFilled
                    ? AppDecorations.avatarRingGradient
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.white5,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: AppColors.white5),
                          ),
                          child: Text(
                            user.tag.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.white50,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.bio,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Connect button
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: isFilled
                          ? Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(9999),
                                boxShadow: AppDecorations.neonShadowPrimary,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: Colors.black, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'Connect',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: AppColors.primary, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'Connect',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

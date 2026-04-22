import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/ambient_background.dart';
import '../../../shared/widgets/glass_nav_bar.dart';
import '../../../shared/widgets/neon_avatar.dart';
import '../providers/chat_provider.dart';

/// Chat dashboard matching `neon_chat_dashboard` design.
/// Features: user header, search bar, active users strip, glass chat cards
/// with unread badges, floating FAB, bottom glass nav bar.
class ChatDashboardScreen extends ConsumerWidget {
  const ChatDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      body: AmbientBackground.dashboard(
        child: Stack(
          children: [
            // ─── Main Content ────────────────────────
            Column(
              children: [
                // Header
                _DashboardHeader(ref: ref),

                // Scrollable content
                Expanded(
                  child: chatRoomsAsync.when(
                    data: (chatRooms) {
                      return ListView(
                        padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 100,
                        ),
                        children: [
                          // Active Now strip
                          _ActiveNowSection(),
                          const SizedBox(height: 16),

                          // Chat list
                          if (chatRooms.isEmpty)
                            _EmptyState()
                          else
                            ...chatRooms.map((room) => _ChatCard(
                                  title: room.lastMessage != null
                                      ? 'Secure Loop'
                                      : 'Secure Loop',
                                  subtitle: room.lastMessage ?? 'Tap to chat',
                                  time: _formatTime(room.updatedAt),
                                  unreadCount: room.unreadCounts.values
                                      .fold(0, (a, b) => a + b),
                                  isOnline: true,
                                  onTap: () => context.push('/chat/${room.id}'),
                                )),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (err, _) => Center(
                      child: Text('Error: $err',
                          style: const TextStyle(color: AppColors.error)),
                    ),
                  ),
                ),
              ],
            ),

            // ─── FAB ─────────────────────────────────
            Positioned(
              bottom: 96,
              right: 20,
              child: _FloatingActionButton(
                onTap: () => context.push('/find-connections'),
              ),
            ),

            // ─── Bottom Nav ──────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassNavBar(
                currentIndex: 0,
                onTap: (index) {
                  if (index == 3) context.push('/profile-settings');
                  if (index == 1) {
                    // TODO: Calls screen
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
      final min = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$min $ampm';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    }
    return '${dateTime.month}/${dateTime.day}';
  }
}

// ─── Header ────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final WidgetRef ref;
  const _DashboardHeader({required this.ref});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          children: [
            // Top row: avatar, title, settings
            Row(
              children: [
                const NeonAvatar(size: 40, showOnlineIndicator: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loopin J',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          shadows: AppDecorations.textGlowWhite,
                        ),
                      ),
                      Text(
                        'ONLINE',
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Settings
                GestureDetector(
                  onTap: () => context.push('/profile-settings'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.glassSurfaceLight,
                    ),
                    child: const Icon(Icons.settings,
                        color: AppColors.white80, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            GestureDetector(
              onTap: () {
                // TODO: Navigate to search
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.glassSurfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.white10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: AppColors.primary,
                            size: 24,
                            shadows: [
                              Shadow(
                                color: AppColors.primary.withValues(alpha: 0.8),
                                blurRadius: 5,
                              ),
                            ]),
                        const SizedBox(width: 12),
                        Text(
                          'Search chats, people...',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Active Now Strip ──────────────────────────────────────
class _ActiveNowSection extends StatelessWidget {
  // Mock data matching the design reference
  static const _activeUsers = [
    _ActiveUser('Cyber', true, true),
    _ActiveUser('Nova', true, false),
    _ActiveUser('Jinx', true, true),
    _ActiveUser('K-9', true, false),
    _ActiveUser('Trinity', true, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'ACTIVE NOW',
            style: TextStyle(
              color: AppColors.white50,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _activeUsers.length,
            separatorBuilder: (_, i) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final user = _activeUsers[index];
              return Column(
                children: [
                  NeonAvatar(
                    size: 56,
                    showOnlineIndicator: true,
                    isOnline: user.isOnline,
                    showRing: user.hasGradientRing,
                    ringGradient: index == 2
                        ? AppDecorations.avatarRingPinkGradient
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: AppColors.white80,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActiveUser {
  final String name;
  final bool isOnline;
  final bool hasGradientRing;
  const _ActiveUser(this.name, this.isOnline, this.hasGradientRing);
}

// ─── Chat Card ─────────────────────────────────────────────
class _ChatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback onTap;

  const _ChatCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x66101C1C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  // Avatar
                  NeonAvatar(
                    size: 56,
                    showOnlineIndicator: isOnline,
                    showRing: unreadCount > 0,
                  ),
                  const SizedBox(width: 16),

                  // Name + Message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              time,
                              style: TextStyle(
                                color: unreadCount > 0
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unreadCount > 0
                                ? AppColors.textSecondary
                                : AppColors.white50,
                            fontSize: 14,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Unread badge
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryPink,
                        boxShadow: AppDecorations.neonShadowPink,
                      ),
                      child: Center(
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.speaker_notes_off,
              size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          const Text(
            'No Active Loops',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect with someone to start\na secure chat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FAB ───────────────────────────────────────────────────
class _FloatingActionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingActionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppDecorations.fabGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: AppColors.white20),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

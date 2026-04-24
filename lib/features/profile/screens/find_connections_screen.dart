import 'dart:developer' as developer;
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
import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/providers/chat_provider.dart';

/// Find connections screen — NOW with real Firestore user data.
class FindConnectionsScreen extends ConsumerStatefulWidget {
  const FindConnectionsScreen({super.key});

  @override
  ConsumerState<FindConnectionsScreen> createState() =>
      _FindConnectionsScreenState();
}

class _FindConnectionsScreenState extends ConsumerState<FindConnectionsScreen> {
  final _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Backfill displayNameLower for any existing users missing it
    // This runs once when the screen opens to migrate old accounts
    ref.read(userServiceProvider).backfillDisplayNameLower();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      final userService = ref.read(userServiceProvider);
      final currentUid = ref.read(authServiceProvider).currentUserId;
      final results = await userService.searchUsers(query, excludeUid: currentUid);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      developer.log('Search error: $e', name: 'FindConnections');
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  /// Start a chat with a user
  Future<void> _startChat(UserModel user) async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final roomId = await chatService.createOrGetChatRoom(user.uid);
      if (mounted) {
        context.push('/chat/$roomId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersProvider);

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
                  onSearch: _performSearch,
                ),

                // ─── Content ─────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 100,
                    ),
                    children: [
                      // Show search results if searching
                      if (_searchController.text.isNotEmpty) ...[
                        _SectionTitle('Search Results'),
                        const SizedBox(height: 12),
                        if (_isSearching)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          )
                        else if (_searchResults.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No users found for "${_searchController.text}"',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 14),
                              ),
                            ),
                          )
                        else
                          ..._searchResults.map((user) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _UserCard(
                                  user: user,
                                  onConnect: () => _startChat(user),
                                  isFilled: true,
                                ),
                              )),
                      ] else ...[
                        // Show all available users
                        _SectionTitle('Available Users'),
                        const SizedBox(height: 12),
                        allUsersAsync.when(
                          data: (users) {
                            if (users.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 60),
                                child: Column(
                                  children: [
                                    Icon(Icons.people_outline,
                                        size: 64,
                                        color: AppColors.textMuted.withValues(alpha: 0.3)),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'No Users Yet',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Be the first to join!\nShare the app with friends.',
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

                            return Column(
                              children: List.generate(users.length, (i) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _UserCard(
                                    user: users[i],
                                    onConnect: () => _startChat(users[i]),
                                    isFilled: i == 0,
                                  ),
                                );
                              }),
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          ),
                          error: (err, _) => Center(
                            child: Text('Error: $err',
                                style: const TextStyle(color: AppColors.error)),
                          ),
                        ),
                      ],
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

// ─── Section Title ─────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: AppColors.white50,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );
  }
}

// ─── Search Header ─────────────────────────────────────────
class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBack;
  final ValueChanged<String> onSearch;

  const _SearchHeader({
    required this.controller,
    required this.onBack,
    required this.onSearch,
  });

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
                            'Find Connections',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search bar — NOW FUNCTIONAL
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
                            onChanged: onSearch,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search by name...',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              controller.clear();
                              onSearch('');
                            },
                            child: const Icon(Icons.close,
                                color: AppColors.textMuted, size: 20),
                          ),
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

// ─── User Card ─────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onConnect;
  final bool isFilled;

  const _UserCard({
    required this.user,
    required this.onConnect,
    this.isFilled = false,
  });

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
                        Flexible(
                          child: Text(
                            user.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Chat button — starts a real chat
                    GestureDetector(
                      onTap: onConnect,
                      child: SizedBox(
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
                                    Icon(Icons.chat_bubble,
                                        color: Colors.black, size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      'Start Chat',
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
                                    Icon(Icons.chat_bubble_outline,
                                        color: AppColors.primary, size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      'Start Chat',
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

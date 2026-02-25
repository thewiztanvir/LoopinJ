import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatDashboardScreen extends ConsumerWidget {
  const ChatDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LoopinJ',
          style: GoogleFonts.outfit(
            color: AppColors.primaryNeon,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: AppColors.primaryNeon, blurRadius: 10)],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search, color: AppColors.secondaryNeon),
            onPressed: () {
              context.push('/find-connections');
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppColors.accentNeon),
            onPressed: () {
              context.push('/profile-settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=2564&auto=format&fit=crop'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: chatRoomsAsync.when(
          data: (chatRooms) {
            if (chatRooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.speaker_notes_off, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
                    const SizedBox(height: 20),
                    Text(
                      'No Active Loops',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Connect with someone to start a secure chat.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final room = chatRooms[index];
                return _ChatRoomTile(
                  title: 'Secure Loop', // TODO: Fetch other user's name
                  subtitle: room.lastMessage ?? 'Tap to chat',
                  onTap: () {
                    context.push('/chat/${room.id}');
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChatRoomTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.glassmorphismBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassmorphismBorder),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.background,
          child: Icon(Icons.person, color: AppColors.primaryNeon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.secondaryNeon),
      ),
    );
  }
}

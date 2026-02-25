import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/glass_text_field.dart';

class ImmersiveChatScreen extends ConsumerStatefulWidget {
  final String chatRoomId;
  const ImmersiveChatScreen({super.key, required this.chatRoomId});

  @override
  ConsumerState<ImmersiveChatScreen> createState() => _ImmersiveChatScreenState();
}

class _ImmersiveChatScreenState extends ConsumerState<ImmersiveChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    // TODO: Fetch remote user's public key from the participants array
    String fakeRemotePublicKey = "PLACEHOLDER"; 
    
    _msgController.clear();
    try {
      await ref.read(chatServiceProvider).sendMessage(widget.chatRoomId, text, fakeRemotePublicKey);
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.chatRoomId));
    final currentUserId = ref.read(chatServiceProvider).currentUserId;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNeon),
          onPressed: () => context.pop(),
        ),
        title: const Text('Secure Loop', style: TextStyle(color: AppColors.primaryNeon)),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call, color: AppColors.secondaryNeon),
            onPressed: () {
              // TODO: Navigate to video call screen
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  return ListView.builder(
                    reverse: true, // Show newest at bottom (requires descending order from Firestore)
                    padding: const EdgeInsets.only(top: 100, bottom: 20, left: 16, right: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUserId;
                      return _MessageBubble(
                        isMe: isMe,
                        cipherText: msg.cipherText, // We'll decrypt this later
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.only(bottom: 30, top: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.8),
        border: const Border(top: BorderSide(color: AppColors.glassmorphismBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GlassTextField(
              controller: _msgController,
              hintText: 'Type an encrypted message...',
              prefixIcon: Icons.lock_outline,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryNeon,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primaryNeon.withOpacity(0.5), blurRadius: 10)
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.background),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final bool isMe;
  final String cipherText;

  const _MessageBubble({required this.isMe, required this.cipherText});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryNeon.withOpacity(0.15) : AppColors.glassmorphismBackground,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : null,
            bottomLeft: !isMe ? const Radius.circular(0) : null,
          ),
          border: Border.all(
            color: isMe ? AppColors.primaryNeon.withOpacity(0.5) : AppColors.glassmorphismBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // Placeholder until decryption is fully bound in UI
              "[Encrypted] $cipherText",
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 10, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('E2EE', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

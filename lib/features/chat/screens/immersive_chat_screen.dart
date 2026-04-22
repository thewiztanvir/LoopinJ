import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/neon_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/chat_provider.dart';

/// Immersive chat room matching `immersive_chat_room` design.
/// Features: neon grid background, glass header with avatar and call buttons,
/// styled bubbles (glass for received, cyan gradient for sent), input bar.
class ImmersiveChatScreen extends ConsumerStatefulWidget {
  final String chatRoomId;
  const ImmersiveChatScreen({super.key, required this.chatRoomId});

  @override
  ConsumerState<ImmersiveChatScreen> createState() =>
      _ImmersiveChatScreenState();
}

class _ImmersiveChatScreenState extends ConsumerState<ImmersiveChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.chatRoomId));

    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // ─── Background ────────────────────────
            Positioned.fill(child: _NeonGridBackground()),

            // Ambient glow
            Positioned(
              top: -80,
              left: -60,
              child: IgnorePointer(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        blurRadius: 120,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Content ───────────────────────────
            Column(
              children: [
                // Header
                _ChatHeader(
                  onBack: () => context.pop(),
                  onVideoCall: () {
                    context.push('/video-call', extra: {
                      'calleeId': 'remote-user',
                      'isCaller': true,
                    });
                  },
                ),

                // Messages
                Expanded(
                  child: messagesAsync.when(
                    data: (messages) {
                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock,
                                  size: 40,
                                  color: AppColors.primary.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              Text(
                                'Encrypted channel ready',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMine =
                              message.senderId ==
                              ref.read(authServiceProvider).currentUserId;

                          // Show timestamp separator for first message
                          // or when date changes
                          Widget? separator;
                          if (index == messages.length - 1 ||
                              messages[index + 1].timestamp.day !=
                                  message.timestamp.day) {
                            separator = _TimestampSeparator(
                              timestamp: message.timestamp,
                            );
                          }

                          return Column(
                            children: [
                              ?separator,
                              _MessageBubble(
                                text: message.cipherText.length > 20
                                    ? 'Encrypted Message'
                                    : message.cipherText,
                                isMine: isMine,
                                time: _formatTime(message.timestamp),
                                isRead: isMine,
                              ),
                            ],
                          );
                        },
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

                // Input bar
                _MessageInputBar(
                  controller: _messageController,
                  onSend: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      // TODO: Call chatService.sendMessage with encryption
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}

// ─── Grid Background ───────────────────────────────────────
class _NeonGridBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Chat Header ───────────────────────────────────────────
class _ChatHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onVideoCall;

  const _ChatHeader({required this.onBack, required this.onVideoCall});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: AppColors.textSecondary, size: 28),
                    onPressed: onBack,
                  ),

                  // Avatar
                  const NeonAvatar(
                    size: 44,
                    showOnlineIndicator: true,
                    showRing: true,
                  ),
                  const SizedBox(width: 12),

                  // Name + Status
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Jinx',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Online',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Video Call
                  _HeaderAction(
                    icon: Icons.videocam,
                    onTap: onVideoCall,
                  ),
                  const SizedBox(width: 8),

                  // Voice Call
                  _HeaderAction(
                    icon: Icons.call,
                    onTap: () {
                      // TODO: Voice call
                    },
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

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white5,
          border: Border.all(color: AppColors.white10),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

// ─── Timestamp Separator ───────────────────────────────────
class _TimestampSeparator extends StatelessWidget {
  final DateTime timestamp;
  const _TimestampSeparator({required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      final h = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
      final m = timestamp.minute.toString().padLeft(2, '0');
      final ampm = timestamp.hour >= 12 ? 'PM' : 'AM';
      label = 'TODAY, $h:$m $ampm';
    } else {
      label = '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white5,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Message Bubble ────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final String time;
  final bool isRead;

  const _MessageBubble({
    required this.text,
    required this.isMine,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Sender avatar for received messages
          if (!isMine) ...[
            const NeonAvatar(size: 28, showRing: false),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isMine
                        ? AppDecorations.sentMessageGradient
                        : null,
                    color: isMine ? null : const Color(0x66101C1C),
                    border: isMine
                        ? null
                        : Border.all(color: AppColors.glassBorder),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMine
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: isMine
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    boxShadow: isMine
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMine
                          ? AppColors.background
                          : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),

                // Read receipt
                if (isMine) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isRead ? 'Read' : 'Sent',
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 12,
                        color: isRead
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message Input Bar ─────────────────────────────────────
class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInputBar({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            border: Border(
              top: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          child: Row(
            children: [
              // Attachment
              GestureDetector(
                onTap: () {
                  // TODO: Attachment picker
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white5,
                  ),
                  child: const Icon(Icons.attach_file,
                      color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(width: 8),

              // Text field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.glassInputBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Emoji picker
                        },
                        child: Icon(Icons.emoji_emotions_outlined,
                            color: AppColors.textMuted, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Send button
              GestureDetector(
                onTap: onSend,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppDecorations.sentMessageGradient,
                    boxShadow: AppDecorations.neonShadowPrimary,
                  ),
                  child: const Icon(Icons.send,
                      color: AppColors.background, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../call/providers/call_provider.dart';

/// Video call screen matching `futuristic_video_call` design.
/// Features: full-screen remote video, vignette overlay, centered name,
/// glass timer with pulsing dot, draggable PiP, HD indicator,
/// 5-button glass control dock (Mute, Video, End, Flip, Chat).
class VideoCallScreen extends ConsumerStatefulWidget {
  final String calleeId;
  final String calleeName;
  final bool isCaller;

  const VideoCallScreen({
    super.key,
    required this.calleeId,
    this.calleeName = 'User',
    required this.isCaller,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isFrontCamera = true;
  int _callSeconds = 0;
  Timer? _timer;

  // PiP position
  double _pipX = 0;
  double _pipY = 0;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _startTimer();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    
    // Wire up WebRTC service callbacks
    final webrtcService = ref.read(webRTCServiceProvider);
    
    webrtcService.onLocalStream = (stream) {
      if (mounted) {
        setState(() {
          _localRenderer.srcObject = stream;
        });
      }
    };
    
    webrtcService.onRemoteStream = (stream) {
      if (mounted) {
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      }
    };
    
    webrtcService.onConnectionState = (state) {
      if (mounted) {
        // Handle connection state changes
        print('WebRTC Connection State: $state');
      }
    };
    
    // Initialize local media stream
    try {
      await webrtcService.initLocalStream(true);
      
      // If we are the caller, initiate the call
      if (widget.isCaller && widget.calleeId.isNotEmpty) {
        await webrtcService.makeCall(widget.calleeId);
      }
    } catch (e) {
      print('Failed to init media: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _callSeconds++);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callSeconds % 60).toString().padLeft(2, '0');
    return '$minutes : $seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _handleEndCall() {
    ref.read(webRTCServiceProvider).endCall();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Initialize PiP position on first build
    if (_pipX == 0 && _pipY == 0) {
      _pipX = screenSize.width - 140;
      _pipY = 120;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── Remote Video (Full Screen) ──────────
          Positioned.fill(
            child: RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),

          // ─── Vignette Overlay ────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppDecorations.vignetteGradient,
              ),
            ),
          ),

          // ─── Top Info ────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // Caller Name
                    Text(
                      widget.calleeName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        shadows: [
                          Shadow(blurRadius: 10, color: Colors.black54),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Timer with pulsing dot
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pulsing dot
                        _PulsingDot(),
                        const SizedBox(width: 8),
                        Text(
                          _formattedTime,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Encrypted badge
                    Text(
                      'ENCRYPTED CONNECTION',
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                        shadows: AppDecorations.textGlow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Draggable PiP ───────────────────────
          Positioned(
            left: _pipX,
            top: _pipY,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _pipX += details.delta.dx;
                  _pipY += details.delta.dy;
                  // Clamp to screen bounds
                  _pipX = _pipX.clamp(0, screenSize.width - 120);
                  _pipY = _pipY.clamp(60, screenSize.height - 180);
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: RTCVideoView(
                          _localRenderer,
                          mirror: _isFrontCamera,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitCover,
                        ),
                      ),
                      // Flip camera overlay
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isFrontCamera = !_isFrontCamera);
                            // TODO: Actually flip camera
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black45,
                            ),
                            child: const Icon(
                              Icons.flip_camera_ios,
                              color: AppColors.textPrimary,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Connection Quality ──────────────────
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Signal bars
                ...List.generate(4, (i) {
                  final isActive = i < 3;
                  return Container(
                    width: 4,
                    height: 8.0 + i * 3,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isActive
                          ? AppColors.primary
                          : AppColors.white20,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  'HD',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // ─── Control Dock ────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0x660A1414),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ControlButton(
                            icon: _isMuted ? Icons.mic_off : Icons.mic,
                            label: 'Mute',
                            isActive: _isMuted,
                            onTap: () {
                              setState(() => _isMuted = !_isMuted);
                              ref.read(webRTCServiceProvider).toggleMute(_isMuted);
                            },
                          ),
                          _ControlButton(
                            icon: _isVideoOff
                                ? Icons.videocam_off
                                : Icons.videocam,
                            label: 'Video',
                            isActive: _isVideoOff,
                            onTap: () {
                              setState(() => _isVideoOff = !_isVideoOff);
                              ref.read(webRTCServiceProvider).toggleCamera(!_isVideoOff);
                            },
                          ),
                          _EndCallButton(onTap: _handleEndCall),
                          _ControlButton(
                            icon: Icons.flip_camera_ios,
                            label: 'Flip',
                            onTap: () {
                              setState(
                                  () => _isFrontCamera = !_isFrontCamera);
                            },
                          ),
                          _ControlButton(
                            icon: Icons.chat_bubble,
                            label: 'Chat',
                            onTap: () {
                              // TODO: Open in-call chat
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pulsing Dot ───────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final opacity = 0.5 + 0.5 * (1 - (2 * value - 1).abs());
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: opacity),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: opacity * 0.6),
                blurRadius: 8,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Control Button ────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.white20
                  : AppColors.white5,
              border: Border.all(color: AppColors.white10),
            ),
            child: Icon(icon,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── End Call Button ───────────────────────────────────────
class _EndCallButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EndCallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -8),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error,
                boxShadow: AppDecorations.neonShadowDanger,
              ),
              child: const Icon(Icons.call_end,
                  color: Colors.white, size: 28),
            ),
          ),
          Text(
            'End',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

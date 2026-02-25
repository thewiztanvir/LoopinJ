import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/call_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final String remoteUserId;
  final bool isCaller;

  const VideoCallScreen({
    super.key, 
    required this.remoteUserId, 
    this.isCaller = true
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    final webrtc = ref.read(webRTCServiceProvider);
    
    webrtc.onLocalStream = (stream) {
      setState(() {
        _localRenderer.srcObject = stream;
      });
    };

    webrtc.onRemoteStream = (stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };

    webrtc.onConnectionState = (state) {
      print('Connection State: $state');
      // Can add UI feedback based on connection disconnected mapping
    };

    // 1. Connect to signaling server
    final currentUserId = ref.read(authServiceProvider).currentUserId;
    if (currentUserId.isNotEmpty) {
      webrtc.connect(currentUserId);
    }
    
    // 2. Start local stream
    await webrtc.initLocalStream(true);

    // 3. If caller, initiate call
    if (widget.isCaller) {
      await webrtc.makeCall(widget.remoteUserId);
    } else {
      // If receiver, they would hit "accept call" from somewhere else
      await webrtc.acceptCall();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    ref.read(webRTCServiceProvider).toggleMute(_isMuted);
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
    ref.read(webRTCServiceProvider).toggleCamera(!_isCameraOff);
  }

  void _endCall() {
    ref.read(webRTCServiceProvider).endCall();
    context.pop();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Immersive full screen
      body: Stack(
        children: [
          // 1. Full Screen Remote Video
          Positioned.fill(
            child: Container(
              color: Colors.black87,
              child: _remoteRenderer.srcObject != null
                  ? RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: AppColors.primaryNeon),
                        const SizedBox(height: 20),
                        Text('Connecting to Secure Loop...', style: TextStyle(color: AppColors.primaryNeon)),
                      ],
                    ),
            ),
          ),
          
          // 2. Top Bar Details
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.glassmorphismBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryNeon),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: AppColors.primaryNeon, size: 14),
                      const SizedBox(width: 6),
                      const Text('E2EE Secured', style: TextStyle(color: AppColors.primaryNeon, fontSize: 12)),
                    ],
                  ),
                ),
                Text('00:00', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // 3. Draggable PIP for Local Video
          Positioned(
            top: 100,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassmorphismBorder, width: 2),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _localRenderer.srcObject != null
                    ? RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                    : const Icon(Icons.person, color: Colors.white, size: 50),
              ),
            ),
          ),

          // 4. Futuristic Call Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? AppColors.error : AppColors.glassmorphismBackground,
                  onPressed: _toggleMute,
                ),
                _buildControlButton(
                  icon: Icons.call_end,
                  color: AppColors.error,
                  size: 64,
                  onPressed: _endCall,
                ),
                _buildControlButton(
                  icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                  color: _isCameraOff ? AppColors.error : AppColors.glassmorphismBackground,
                  onPressed: _toggleCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required Color color, double size = 56, required VoidCallback onPressed}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassmorphismBorder),
        boxShadow: color == AppColors.error ? [BoxShadow(color: AppColors.error.withOpacity(0.5), blurRadius: 10)] : [],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size * 0.5),
        onPressed: onPressed,
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef PeerConnectionStateCallback = void Function(RTCPeerConnectionState state);
typedef LocalStreamCallback = void Function(MediaStream stream);
typedef RemoteStreamCallback = void Function(MediaStream stream);
typedef IncomingCallCallback = void Function(String callerId);

class WebRTCService {
  IO.Socket? _socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  String? _currentUserId;
  String? _remoteUserId;

  PeerConnectionStateCallback? onConnectionState;
  LocalStreamCallback? onLocalStream;
  RemoteStreamCallback? onRemoteStream;
  IncomingCallCallback? onIncomingCall;

  // The local IP of the node server for testing, or Render URL for production
  final String _signalingServerUrl = 'http://10.0.2.2:3000'; // Adjust based on emulator/device

  // Provided Metered TURN Server config
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'}, // Fallback Google STUN
      {
        'urls': 'turn:loopinj.metered.live:80',
        'username': 'dMxq61psh7S2NpNU99NpOI05Xq32tyfqb_DpF1I5FpuN613A',
        'credential': 'dMxq61psh7S2NpNU99NpOI05Xq32tyfqb_DpF1I5FpuN613A'
      }
    ]
  };

  /// Initialize the socket to the signaling server
  void connect(String userId) {
    _currentUserId = userId;
    
    _socket = IO.io(_signalingServerUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      print('Connected to signaling server');
      _socket!.emit('register', userId);
    });

    // Listeners for WebRTC Signaling
    _socket!.on('offer', (data) async {
      final callerId = data['callerId'];
      final sdpData = data['sdp'];
      _remoteUserId = callerId;
      
      if (onIncomingCall != null) {
        // Trigger UI for answering
        onIncomingCall!(callerId); 
      }
      
      // Real app might wait for user to hit "accept", for now, we simply prepare it
      await _handleIncomingOffer(callerId, sdpData);
    });

    _socket!.on('answer', (data) async {
      await _handleIncomingAnswer(data['sdp']);
    });

    _socket!.on('ice_candidate', (data) async {
      await _handleIceCandidate(data['candidate']);
    });

    _socket!.on('end_call', (_) {
      endCall();
    });
  }

  /// Prepare local media and peer connection
  Future<void> initLocalStream(bool videoEnabled) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': videoEnabled ? {
        'mandatory': {
          'minWidth': '640', 
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
      } : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    if (onLocalStream != null) {
      onLocalStream!(_localStream!);
    }
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final pc = await createPeerConnection(_configuration, {});

    // Add local stream tracks to PeerConnection
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        pc.addTrack(track, _localStream!);
      });
    }

    pc.onIceCandidate = (candidate) {
      if (_remoteUserId != null) {
        _socket!.emit('ice_candidate', {
          'targetUserId': _remoteUserId,
          'senderId': _currentUserId,
          'candidate': candidate.toMap(),
        });
      }
    };

    pc.onConnectionState = (state) {
      if (onConnectionState != null) {
        onConnectionState!(state);
      }
    };

    pc.onAddStream = (stream) {
      _remoteStream = stream;
      if (onRemoteStream != null) {
        onRemoteStream!(_remoteStream!);
      }
    };

    return pc;
  }

  /// Start a call to a target user
  Future<void> makeCall(String targetUserId) async {
    _remoteUserId = targetUserId;
    _peerConnection = await _createPeerConnection();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _socket!.emit('offer', {
      'targetUserId': targetUserId,
      'callerId': _currentUserId,
      'sdp': offer.toMap(),
    });
  }

  Future<void> _handleIncomingOffer(String callerId, Map<String, dynamic> sdpMap) async {
    _peerConnection = await _createPeerConnection();
    final offerData = RTCSessionDescription(sdpMap['sdp'], sdpMap['type']);
    await _peerConnection!.setRemoteDescription(offerData);
  }

  /// Call this when the user clicks 'Accept' on an incoming call UI
  Future<void> acceptCall() async {
    if (_peerConnection == null || _remoteUserId == null) return;
    
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _socket!.emit('answer', {
      'targetUserId': _remoteUserId,
      'callerId': _currentUserId,
      'sdp': answer.toMap(),
    });
  }

  Future<void> _handleIncomingAnswer(Map<String, dynamic> sdpMap) async {
    final answerData = RTCSessionDescription(sdpMap['sdp'], sdpMap['type']);
    await _peerConnection!.setRemoteDescription(answerData);
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> candidateMap) async {
    final candidate = RTCIceCandidate(
      candidateMap['candidate'],
      candidateMap['sdpMid'],
      candidateMap['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(candidate);
  }

  /// End the call, stop tracks, and emit close signal
  void endCall() {
    if (_remoteUserId != null && _socket != null) {
      _socket!.emit('end_call', {
        'targetUserId': _remoteUserId,
        'senderId': _currentUserId,
      });
    }
    
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.close();
    
    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
    _remoteUserId = null;
  }

  void toggleMute(bool isMuted) {
    if (_localStream != null) {
      _localStream!.getAudioTracks()[0].enabled = !isMuted;
    }
  }

  void toggleCamera(bool isEnabled) {
    if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
      _localStream!.getVideoTracks()[0].enabled = isEnabled;
    }
  }
}

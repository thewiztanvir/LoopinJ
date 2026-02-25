import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/webrtc_service.dart';

final webRTCServiceProvider = Provider<WebRTCService>((ref) {
  return WebRTCService();
});

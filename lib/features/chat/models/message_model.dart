enum MessageStatus { sent, delivered, seen }

class MessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String cipherText; // AES Encrypted payload
  final String nonce;      // Used for AES decryption
  final String mac;        // Message auth code used in AES-GCM
  final DateTime timestamp;
  final MessageStatus status;

  MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.cipherText,
    required this.nonce,
    required this.mac,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data, String documentId) {
    return MessageModel(
      id: documentId,
      chatRoomId: data['chatRoomId'] ?? '',
      senderId: data['senderId'] ?? '',
      cipherText: data['cipherText'] ?? '',
      nonce: data['nonce'] ?? '',
      mac: data['mac'] ?? '',
      timestamp: data['timestamp'] != null ? DateTime.parse(data['timestamp']) : DateTime.now(),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'cipherText': cipherText,
      'nonce': nonce,
      'mac': mac,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cryptography/cryptography.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../../../core/services/crypto_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CryptoService _cryptoService;

  ChatService(this._cryptoService);

  String get currentUserId => _auth.currentUser?.uid ?? '';

  /// Stream of chat rooms the current user is a part of
  Stream<List<ChatRoomModel>> getChatRooms() {
    if (currentUserId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('chatRooms')
        .where('participantIds', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatRoomModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Stream of messages for a specific chat room
  Stream<List<MessageModel>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Gets or creates a 1-to-1 chat room with another user
  Future<String> createOrGetChatRoom(String otherUserId) async {
    final participants = [currentUserId, otherUserId]..sort();
    
    // Check if room exists
    final query = await _firestore
        .collection('chatRooms')
        .where('participantIds', isEqualTo: participants)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }

    // Create new room
    final roomRef = _firestore.collection('chatRooms').doc();
    final newRoom = ChatRoomModel(
      id: roomRef.id,
      participantIds: participants,
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
      unreadCounts: {currentUserId: 0, otherUserId: 0},
    );

    await roomRef.set(newRoom.toMap());
    return roomRef.id;
  }

  /// Sends an E2EE message to a chat room
  Future<void> sendMessage(String chatRoomId, String text, String remotePublicKeyBase64) async {
    // 1. Derive Shared Secret
    final sharedSecret = await _cryptoService.deriveSharedSecret(remotePublicKeyBase64);
    
    // 2. Encrypt Payload
    final encryptedData = await _cryptoService.encryptMessage(text, sharedSecret);
    
    // 3. Create Message Model
    final messageRef = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc();
        
    final message = MessageModel(
      id: messageRef.id,
      chatRoomId: chatRoomId,
      senderId: currentUserId,
      cipherText: encryptedData['cipherText']!,
      nonce: encryptedData['nonce']!,
      mac: encryptedData['mac']!,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    // 4. Batch Write (Save message & update room updatedAt)
    final batch = _firestore.batch();
    batch.set(messageRef, message.toMap());
    
    final roomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    batch.update(roomRef, {
      'updatedAt': DateTime.now().toIso8601String(),
      'lastMessage': 'Encrypted Message', // Do not store plaintext in the room overview
    });
    
    await batch.commit();
  }

  /// Decrypts a message payload
  Future<String> decryptMessagePayload(MessageModel message, String remotePublicKeyBase64) async {
    try {
      final sharedSecret = await _cryptoService.deriveSharedSecret(remotePublicKeyBase64);
      return await _cryptoService.decryptMessage(
        message.cipherText, 
        message.nonce, 
        message.mac, 
        sharedSecret
      );
    } catch (e) {
      return "[Decryption Failed]";
    }
  }
}

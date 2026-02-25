class ChatRoomModel {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime updatedAt;
  final DateTime createdAt;
  final Map<String, int> unreadCounts; // Map of userId -> count

  ChatRoomModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    required this.updatedAt,
    required this.createdAt,
    required this.unreadCounts,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ChatRoomModel(
      id: documentId,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      lastMessage: data['lastMessage'],
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : DateTime.now(),
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'unreadCounts': unreadCounts,
    };
  }
}

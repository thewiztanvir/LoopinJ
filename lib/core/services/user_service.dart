import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Service for fetching user profiles from Firestore.
/// Used across the app to resolve participant IDs to display names,
/// fetch public keys for E2EE, and search for new connections.
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch a single user by their UID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Fetch multiple users by their UIDs in a single batch
  Future<Map<String, UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return {};
    
    final Map<String, UserModel> result = {};
    // Firestore 'whereIn' supports max 10 items per query
    for (var i = 0; i < uids.length; i += 10) {
      final batch = uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10);
      final query = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      for (final doc in query.docs) {
        result[doc.id] = UserModel.fromMap(doc.data(), doc.id);
      }
    }
    return result;
  }

  /// Search users by display name (case-insensitive prefix match)
  Future<List<UserModel>> searchUsers(String query, {String? excludeUid}) async {
    if (query.trim().isEmpty) return [];

    // Firestore doesn't support full-text search natively.
    // We use a prefix range query on the displayName field.
    final lowerQuery = query.toLowerCase();
    final upperBound = '${lowerQuery.substring(0, lowerQuery.length - 1)}${String.fromCharCode(lowerQuery.codeUnitAt(lowerQuery.length - 1) + 1)}';

    final snapshot = await _firestore
        .collection('users')
        .where('displayNameLower', isGreaterThanOrEqualTo: lowerQuery)
        .where('displayNameLower', isLessThan: upperBound)
        .limit(20)
        .get();

    final users = snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .where((u) => excludeUid == null || u.uid != excludeUid)
        .toList();

    return users;
  }

  /// Get all users except the current user (for Find Connections)
  Future<List<UserModel>> getAllUsers({String? excludeUid}) async {
    final snapshot = await _firestore.collection('users').limit(50).get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .where((u) => excludeUid == null || u.uid != excludeUid)
        .toList();
  }
}

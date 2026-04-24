import 'dart:developer' as developer;
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

    final lowerQuery = query.toLowerCase();

    // Strategy 1: Try Firestore prefix query on displayNameLower
    try {
      final upperBound = '${lowerQuery.substring(0, lowerQuery.length - 1)}${String.fromCharCode(lowerQuery.codeUnitAt(lowerQuery.length - 1) + 1)}';
      
      developer.log('Searching users: query="$lowerQuery"', name: 'UserService');
      
      final snapshot = await _firestore
          .collection('users')
          .where('displayNameLower', isGreaterThanOrEqualTo: lowerQuery)
          .where('displayNameLower', isLessThan: upperBound)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        developer.log('Firestore query returned ${snapshot.docs.length} results', name: 'UserService');
        return snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .where((u) => excludeUid == null || u.uid != excludeUid)
            .toList();
      }
    } catch (e) {
      developer.log('Firestore search failed, using fallback: $e', name: 'UserService');
    }

    // Strategy 2: Fallback — fetch all users and filter client-side
    // This handles the case where displayNameLower doesn't exist on old docs
    developer.log('Falling back to client-side search', name: 'UserService');
    final allSnapshot = await _firestore.collection('users').limit(50).get();
    final users = allSnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .where((u) => excludeUid == null || u.uid != excludeUid)
        .where((u) =>
            u.displayName.toLowerCase().contains(lowerQuery) ||
            u.email.toLowerCase().contains(lowerQuery))
        .toList();

    developer.log('Client-side search found ${users.length} results', name: 'UserService');
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

  /// Backfill 'displayNameLower' for existing users who don't have it.
  /// Call this once on sign-in to migrate old accounts.
  Future<void> backfillDisplayNameLower() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final batch = _firestore.batch();
      int count = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('displayNameLower') || data['displayNameLower'] == null) {
          final displayName = data['displayName'] ?? '';
          batch.update(doc.reference, {
            'displayNameLower': displayName.toString().toLowerCase(),
          });
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        developer.log('Backfilled displayNameLower for $count users', name: 'UserService');
      }
    } catch (e) {
      developer.log('Backfill error: $e', name: 'UserService');
    }
  }
}


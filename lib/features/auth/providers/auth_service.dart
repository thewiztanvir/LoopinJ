import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/crypto_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CryptoService _cryptoService;

  AuthService(this._cryptoService);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    }
    return null;
  }

  Future<UserModel> signUpWithEmail(String email, String password, String displayName) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String pkBase64 = await _cryptoService.generateAndStoreKeyPair();

      final userModel = UserModel(
        uid: cred.user!.uid,
        email: email,
        displayName: displayName,
        publicKey: pkBase64,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
      );

      await _firestore.collection('users').doc(userModel.uid).set(userModel.toMap());
      await cred.user!.updateDisplayName(displayName);

      return userModel;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  Future<void> updateLastSeen() async {
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'lastSeen': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> signOut() async {
    await updateLastSeen();
    await _auth.signOut();
  }
}

import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // We need to add this to pubspec

class CryptoService {
  final _algorithm = X25519();
  final _storage = const FlutterSecureStorage();
  
  static const String _privateKeyStorageKey = 'e2ee_private_key';

  /// Generates a new X25519 key pair, stores the private key securely on device,
  /// and returns the Base64 encoded public key to be saved in Firestore.
  Future<String> generateAndStoreKeyPair() async {
    final keyPair = await _algorithm.newKeyPair();
    
    // Extract private key bytes
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final privateKeyBase64 = base64Encode(privateKeyBytes);
    
    // Store securely
    await _storage.write(key: _privateKeyStorageKey, value: privateKeyBase64);
    
    // Extract public key
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBase64 = base64Encode(publicKey.bytes);
    
    return publicKeyBase64;
  }

  /// Retrieves the stored private key
  Future<List<int>?> getPrivateKeyBytes() async {
    final b64 = await _storage.read(key: _privateKeyStorageKey);
    if (b64 == null) return null;
    return base64Decode(b64);
  }

  /// Derives a shared secret for symmetric encryption (AES-GCM) 
  /// using the local private key and a remote user's public key.
  Future<SecretKey> deriveSharedSecret(String remotePublicKeyBase64) async {
    final localKeyBytes = await getPrivateKeyBytes();
    if (localKeyBytes == null) {
      throw Exception('Private key not found on device.');
    }
    
    final localKeyPair = await _algorithm.newKeyPairFromSeed(localKeyBytes);
    final remoteBytes = base64Decode(remotePublicKeyBase64);
    final remotePublicKey = SimplePublicKey(remoteBytes, type: KeyPairType.x25519);
    
    final sharedSecret = await _algorithm.sharedSecretKey(
      keyPair: localKeyPair,
      remotePublicKey: remotePublicKey,
    );
    
    return sharedSecret;
  }
  
  /// Encrypts a message using AES-GCM with the derived shared secret.
  Future<Map<String, String>> encryptMessage(String plainText, SecretKey sharedSecret) async {
    final cipher = AesGcm.with256bits();
    final secretBox = await cipher.encrypt(
      utf8.encode(plainText),
      secretKey: sharedSecret,
    );
    
    return {
      'cipherText': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
      'nonce': base64Encode(secretBox.nonce),
    };
  }
  
  /// Decrypts a message using AES-GCM with the derived shared secret.
  Future<String> decryptMessage(String cipherTextB64, String nonceB64, String macB64, SecretKey sharedSecret) async {
    final cipher = AesGcm.with256bits();
    final secretBox = SecretBox(
      base64Decode(cipherTextB64),
      nonce: base64Decode(nonceB64),
      mac: Mac(base64Decode(macB64)),
    );
    
    final clearTextBytes = await cipher.decrypt(
      secretBox,
      secretKey: sharedSecret,
    );
    
    return utf8.decode(clearTextBytes);
  }
}

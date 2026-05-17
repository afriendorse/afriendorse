import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TwoFactorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String generateCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<String> createSession({required String email}) async {
    final code = generateCode();
    final docRef = _firestore.collection('two_factor_sessions').doc();

    await docRef.set({
      'email': email.trim().toLowerCase(),
      'code': code,
      'verified': false,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 5)),
      ),
    });

    if (kDebugMode) {
      print('2FA Code for $email => $code');
    }

    return docRef.id;
  }

  static Future<String?> getSessionCode(String sessionId) async {
    final doc = await _firestore
        .collection('two_factor_sessions')
        .doc(sessionId)
        .get();
    return doc.data()?['code']?.toString();
  }

  static Future<bool> verifyCode({
    required String sessionId,
    required String code,
  }) async {
    final docRef = _firestore.collection('two_factor_sessions').doc(sessionId);
    final doc = await docRef.get();

    if (!doc.exists) return false;

    final data = doc.data()!;
    final storedCode = data['code']?.toString();
    final verified = data['verified'] == true;
    final Timestamp? expiresAt = data['expiresAt'];

    if (verified) return false;
    if (storedCode != code) return false;
    if (expiresAt == null || expiresAt.toDate().isBefore(DateTime.now())) {
      return false;
    }

    await docRef.update({
      'verified': true,
      'verifiedAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  static Future<String?> resendCode({required String sessionId}) async {
    final docRef = _firestore.collection('two_factor_sessions').doc(sessionId);
    final doc = await docRef.get();

    if (!doc.exists) return null;

    final newCode = generateCode();

    await docRef.update({
      'code': newCode,
      'verified': false,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 5)),
      ),
    });

    return newCode;
  }
}

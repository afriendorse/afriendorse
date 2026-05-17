///brand/fan firestore logic

import 'package:afriendorse/feature/referral/repository/referral_reward_service.dart';
import 'package:afriendorse/feature/referral/repository/referral_tracking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> _resolveUserDocId(String email) async {
    final raw = email.trim();
    final lower = raw.toLowerCase();

    final lowerSnap = await _firestore.collection('users').doc(lower).get();
    if (lowerSnap.exists) return lower;

    final rawSnap = await _firestore.collection('users').doc(raw).get();
    if (rawSnap.exists) return raw;

    return lower;
  }

  static Future<void> syncUserToFirestore({
    required String email,
    required String? phone,
    required String firstName,
    required String lastName,
    required String userType,
    String? mysqlUserId,
    String? fcmToken,
  }) async {
    try {
      final docId = await _resolveUserDocId(email);
      final hasMysqlId = mysqlUserId != null && mysqlUserId.trim().isNotEmpty;

      await _firestore.collection('users').doc(docId).set({
        'userId': docId,
        'email': docId,
        'emailLower': docId.toLowerCase(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'firstName': firstName,
        'lastName': lastName,
        'userType': userType,
        'mysqlUserId': hasMysqlId ? mysqlUserId : null,
        'hasMysqlUserId': hasMysqlId,
        'isActive': true,
        'fcmToken': fcmToken,
        'profileComplete': userType == 'fan',
        'welcomeEmailSent': false, // Reset to allow welcome email
        'welcomePushSent': false, // Reset to allow welcome push

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (userType == 'fan') {
        await _firestore.collection('fans').doc(docId).set({
          'userId': docId,
          'email': docId,
          'mysqlUserId': hasMysqlId ? mysqlUserId : null,
          'favoriteAthletes': [],
          'interests': [],
          'engagementScore': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (userType == 'brand') {
        await _firestore.collection('brands').doc(docId).set({
          'userId': docId,
          'email': docId,
          'mysqlUserId': hasMysqlId ? mysqlUserId : null,
          'brandName': null,
          'industry': null,
          'cacNumber': null,
          'brandDescription': null,
          'cacDocumentUrl': null,
          'verificationStatus': 'pending',
          'isVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (kDebugMode) {
        print('✅ User synced to Firestore: docId=$docId as $userType');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firestore sync error: $e');
      }
    }
  }

  static Future<void> updateMysqlUserId(
    String email,
    String mysqlUserId,
  ) async {
    try {
      final docId = await _resolveUserDocId(email);

      final userSnap = await _firestore.collection('users').doc(docId).get();
      final userType = userSnap.data()?['userType']?.toString();

      await _firestore.collection('users').doc(docId).set({
        'userId': docId,
        'email': docId,
        'emailLower': docId.toLowerCase(),
        'mysqlUserId': mysqlUserId,
        'hasMysqlUserId': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (userType == 'fan') {
        await _firestore.collection('fans').doc(docId).set({
          'userId': docId,
          'email': docId,
          'mysqlUserId': mysqlUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else if (userType == 'brand') {
        await _firestore.collection('brands').doc(docId).set({
          'userId': docId,
          'email': docId,
          'mysqlUserId': mysqlUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating MySQL user ID: $e');
      }
    }
  }

  // lib/feature/auth/repository/firestore_sync_service.dart
  // REPLACE THE completeUserReferralIfExists METHOD WITH THIS UPDATED VERSION

  static Future<void> completeUserReferralIfExists(String userEmail) async {
    try {
      // Mark referral as completed
      final completed = await ReferralTrackingService.completeReferral(
        refereeEmail: userEmail,
      );

      if (completed) {
        // Find the referral to get referrer info
        final snapshot = await FirebaseFirestore.instance
            .collection('referrals')
            .where('refereeId', isEqualTo: userEmail.trim().toLowerCase())
            .where('status', isEqualTo: 'completed')
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final referralData = snapshot.docs.first.data();
          final referrerId = referralData['referrerId'] as String;
          final referrerType = referralData['referrerType'] as String;
          final refereeType = referralData['refereeType'] as String;
          final referralId = snapshot.docs.first.id;

          // Award points for user referrals (skip brands for now)
          if (refereeType != 'brand') {
            // 🆕 Award points to REFERRER (person who referred)
            await ReferralRewardService.awardUserReferralPoints(
              referrerEmail: referrerId,
              referrerType: referrerType,
              refereeEmail: userEmail,
              referralId: referralId,
            );

            // 🆕 Award WELCOME points to REFEREE (person who signed up with code)
            await ReferralRewardService.awardRefereeWelcomePoints(
              refereeEmail: userEmail,
              refereeType: refereeType,
              referralId: referralId,
            );

            if (kDebugMode) {
              print('✅ Both referrer and referee rewarded for referral!');
            }
          }
          // Note: Brand referrals get commission later when deal is approved
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error completing user referral: $e');
      }
    }
  }

  static Future<void> completeBrandProfile({
    required String email,
    required String brandName,
    required String industry,
    required String cacNumber,
    required String brandDescription,
    required String cacDocumentUrl,
  }) async {
    final docId = await _resolveUserDocId(email);

    await _firestore.collection('brands').doc(docId).set({
      'brandName': brandName,
      'industry': industry,
      'cacNumber': cacNumber,
      'brandDescription': brandDescription,
      'cacDocumentUrl': cacDocumentUrl,
      'verificationStatus': 'pending',
      'isVerified': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.collection('users').doc(docId).set({
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getBrandByEmail(String email) async {
    try {
      final docId = await _resolveUserDocId(email);
      final doc = await _firestore.collection('brands').doc(docId).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchBrandByEmail(
    String email,
  ) async* {
    final docId = await _resolveUserDocId(email);
    yield* _firestore.collection('brands').doc(docId).snapshots();
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final docId = await _resolveUserDocId(email);
      final doc = await _firestore.collection('users').doc(docId).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> updateTwoFactorPreference({
    required String email,
    required bool enabled,
  }) async {
    try {
      final docId = await _resolveUserDocId(email);
      await _firestore.collection('users').doc(docId).set({
        'twoFactorEnabled': enabled,
        'twoFactorMethod': 'email',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> getTwoFactorPreference(String email) async {
    try {
      final docId = await _resolveUserDocId(email);
      final doc = await _firestore.collection('users').doc(docId).get();
      return doc.data()?['twoFactorEnabled'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> updateFcmToken(String email, String token) async {
    final docId = await _resolveUserDocId(email);
    await _firestore.collection('users').doc(docId).set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

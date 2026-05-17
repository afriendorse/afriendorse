import 'package:afriendorse/feature/referral/repository/referral_reward_service.dart';
import 'package:afriendorse/feature/referral/repository/referral_tracking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AthleteFirestoreSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> _resolveAthleteDocId(String email) async {
    final raw = email.trim();
    final lower = raw.toLowerCase();

    final lowerSnap = await _firestore.collection('athletes').doc(lower).get();
    if (lowerSnap.exists) return lower;

    final rawSnap = await _firestore.collection('athletes').doc(raw).get();
    if (rawSnap.exists) return raw;

    return lower;
  }

  static Future<void> syncAthleteToFirestore({
    required String userId,
    required String email,
    required String? phone,
    required String firstName,
    required String lastName,
    required String companyName,
    required String fieldOfSport,
    String? mysqlAthleteId,
    String? fcmToken,
  }) async {
    try {
      final docId = await _resolveAthleteDocId(email);
      final hasId =
          (mysqlAthleteId != null && mysqlAthleteId.trim().isNotEmpty);

      final athleteData = {
        'userId': docId,
        'email': docId,
        'emailLower': docId.toLowerCase(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'firstName': firstName,
        'lastName': lastName,
        'companyName': companyName,
        'fieldOfSport': fieldOfSport,
        'mysqlAthleteId': hasId ? mysqlAthleteId : null,
        'hasMysqlAthleteId': hasId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'fcmToken': fcmToken,
        'profileComplete': false,
        'userType': 'athlete',

        // Badge verification fields only — DO NOT use for login access
        'verificationStatus': 'unverified',
        'isVerified': false,
        'showVerificationBadge': false,
      };

      await _firestore
          .collection('athletes')
          .doc(docId)
          .set(athleteData, SetOptions(merge: true));

      await _firestore.collection('athlete_profiles').doc(docId).set({
        'userId': docId,
        'mysqlAthleteId': hasId ? mysqlAthleteId : null,
        'achievements': [],
        'stats': {},
        'followersCount': 0,
        'followingCount': 0,
        'dealsCompleted': 0,
        'earnings': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print(
          '✅ Athlete synced to Firestore: docId=$docId | badgeStatus=unverified',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firestore sync error: $e');
      }
    }
  }

  static Future<void> completeAthleteReferralIfExists(String userEmail) async {
    try {
      final completed = await ReferralTrackingService.completeReferral(
        refereeEmail: userEmail,
      );

      if (completed) {
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

          // Award points for user referrals (skip brands)
          if (refereeType != 'brand') {
            // Award points to REFERRER
            await ReferralRewardService.awardUserReferralPoints(
              referrerEmail: referrerId,
              referrerType: referrerType,
              refereeEmail: userEmail,
              referralId: referralId,
            );

            // Award WELCOME points to REFEREE
            await ReferralRewardService.awardRefereeWelcomePoints(
              refereeEmail: userEmail,
              refereeType: refereeType,
              referralId: referralId,
            );

            if (kDebugMode) {
              print('✅ Athlete referral completed: both users rewarded!');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error completing athlete referral: $e');
      }
    }
  }

  static Future<void> updateAthleteMediaKit({
    required String email,
    required String sportId,
    required String sportName,
    required String bio,
    required String schoolTeam,
    required String positionRole,
    required String jerseyNumber,
    required String classYear,
    required String publicLocation,
    required List<String> gallery,
    required List<String> languages,
    required List<String> interests,
    required List<String> awards,
    required Map<String, String> socials,
    required Map<String, String> socialStats,
    required int profileCompleteness,
  }) async {
    final docId = email.trim().toLowerCase();

    await _firestore.collection('athlete_profiles').doc(docId).set({
      'userId': docId,
      'email': docId,
      'sportId': sportId,
      'sportName': sportName,
      'bio': bio,
      'schoolTeam': schoolTeam,
      'positionRole': positionRole,
      'jerseyNumber': jerseyNumber,
      'classYear': classYear,
      'publicLocation': publicLocation,
      'gallery': gallery,
      'languages': languages,
      'interests': interests,
      'awards': awards,
      'socials': socials,
      'socialStats': socialStats,
      'profileCompleteness': profileCompleteness,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.collection('athletes').doc(docId).set({
      'schoolTeam': schoolTeam,
      'positionRole': positionRole,
      'publicLocation': publicLocation,
      'sportName': sportName,
      'profileCompleteness': profileCompleteness,
      if (gallery.isNotEmpty) 'galleryCover': gallery.first,
      'socialStats': socialStats,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> upsertAthleteListingFields({
    required String email,
    required String mysqlAthleteId,
    String? phone,
    String? companyName,
    String? companyAddress,
    String? logoFullPath,
    String? coverImageFullPath,
    double? avgRating,
    int? ratingCount,
    String? fieldOfSport,
    double? lat,
    double? lon,
    String? zoneId,
  }) async {
    try {
      final docId = email.trim().toLowerCase();

      await _firestore.collection('athletes').doc(docId).set({
        'userId': docId,
        'email': docId,
        'emailLower': docId.toLowerCase(),
        'mysqlAthleteId': mysqlAthleteId,
        'hasMysqlAthleteId': true,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (companyName != null) 'companyName': companyName,
        if (companyAddress != null) 'companyAddress': companyAddress,
        if (logoFullPath != null) 'logoFullPath': logoFullPath,
        if (coverImageFullPath != null)
          'coverImageFullPath': coverImageFullPath,
        if (avgRating != null) 'avgRating': avgRating,
        if (ratingCount != null) 'ratingCount': ratingCount,
        if (fieldOfSport != null) 'fieldOfSport': fieldOfSport,
        if (zoneId != null) 'zoneId': zoneId,
        if (lat != null && lon != null)
          'coordinates': {'latitude': lat, 'longitude': lon},
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'userType': 'athlete',
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ upsertAthleteListingFields() synced for $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ upsertAthleteListingFields error: $e');
      }
    }
  }

  /// Call this when admin approves an athlete from the backend panel.
  /// Flips verificationStatus to 'approved' so they appear in listings.
  static Future<void> approveAthlete(String email) async {
    try {
      final docId = await _resolveAthleteDocId(email);

      await _firestore.collection('athletes').doc(docId).set({
        'verificationStatus': 'verified',
        'isVerified': true,
        'showVerificationBadge': true,
        'verifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Athlete badge verified in Firestore: docId=$docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ approveAthlete error: $e');
      }
    }
  }

  /// Call this when admin rejects/suspends an athlete.
  /// Flips verificationStatus to 'rejected' hiding them from listings.
  static Future<void> rejectAthlete(String email, {String? reason}) async {
    try {
      final docId = await _resolveAthleteDocId(email);

      await _firestore.collection('athletes').doc(docId).set({
        'verificationStatus': 'rejected',
        'isVerified': false,
        'showVerificationBadge': false,
        if (reason != null && reason.isNotEmpty) 'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Athlete verification rejected in Firestore: docId=$docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ rejectAthlete error: $e');
      }
    }
  }

  static Future<void> verifyAthleteBadge(String email) async {
    try {
      final docId = await _resolveAthleteDocId(email);

      await _firestore.collection('athletes').doc(docId).set({
        'verificationStatus': 'verified',
        'isVerified': true,
        'showVerificationBadge': true,
        'verifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Athlete badge verified: docId=$docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ verifyAthleteBadge error: $e');
      }
    }
  }

  static Future<void> removeAthleteBadge(String email) async {
    try {
      final docId = await _resolveAthleteDocId(email);

      await _firestore.collection('athletes').doc(docId).set({
        'verificationStatus': 'unverified',
        'isVerified': false,
        'showVerificationBadge': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Athlete badge removed: docId=$docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ removeAthleteBadge error: $e');
      }
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> athleteDocStream(
    String email,
  ) {
    final docId = email.trim().toLowerCase();
    return _firestore.collection('athletes').doc(docId).snapshots();
  }

  static Future<void> setVerificationPending(String email) async {
    final docId = await _resolveAthleteDocId(email);

    await _firestore.collection('athletes').doc(docId).set({
      'verificationStatus': 'pending',
      'isVerified': false,
      'showVerificationBadge': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> updateMysqlAthleteId(
    String email,
    String mysqlAthleteId,
  ) async {
    try {
      final docId = await _resolveAthleteDocId(email);

      await _firestore.collection('athletes').doc(docId).set({
        'userId': docId,
        'email': docId,
        'emailLower': docId.toLowerCase(),
        'mysqlAthleteId': mysqlAthleteId,
        'hasMysqlAthleteId': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'userType': 'athlete',
        'isActive': true,
        // Do NOT touch verificationStatus here — it was already set
        // correctly during syncAthleteToFirestore or upsertAthleteListingFields
      }, SetOptions(merge: true));

      await _firestore.collection('athlete_profiles').doc(docId).set({
        'userId': docId,
        'mysqlAthleteId': mysqlAthleteId,
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print(
          '✅ Firestore patched mysqlAthleteId=$mysqlAthleteId for docId=$docId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating MySQL athlete ID: $e');
      }
    }
  }

  static Future<Map<String, dynamic>?> getAthleteProfileByEmail(
    String email,
  ) async {
    try {
      final docId = await _resolveAthleteDocId(email);

      final doc = await _firestore
          .collection('athlete_profiles')
          .doc(docId)
          .get();
      return doc.data();
    } catch (e) {
      if (kDebugMode) {
        print('❌ getAthleteProfileByEmail error: $e');
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAthleteByEmail(String email) async {
    try {
      final docId = await _resolveAthleteDocId(email);
      final doc = await _firestore.collection('athletes').doc(docId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Returns the verificationStatus of an athlete.
  /// 'pending' | 'approved' | 'rejected' | null (doc not found)
  static Future<String?> getVerificationStatus(String email) async {
    try {
      final docId = await _resolveAthleteDocId(email);
      final doc = await _firestore.collection('athletes').doc(docId).get();
      return doc.data()?['verificationStatus'] as String?;
    } catch (e) {
      if (kDebugMode) {
        print('❌ getVerificationStatus error: $e');
      }
      return null;
    }
  }

  static Future<String?> getAthleteFieldOfSport(String email) async {
    try {
      final docId = await _resolveAthleteDocId(email);
      final doc = await _firestore.collection('athletes').doc(docId).get();
      return doc.data()?['fieldOfSport'] as String?;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateFcmToken(String email, String token) async {
    final docId = await _resolveAthleteDocId(email);
    await _firestore.collection('athletes').doc(docId).set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<bool> updateTwoFactorPreference({
    required String email,
    required bool enabled,
  }) async {
    try {
      final docId = await _resolveAthleteDocId(email);
      await _firestore.collection('athletes').doc(docId).set({
        'twoFactorEnabled': enabled,
        'twoFactorMethod': 'email',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> getTwoFactorPreference(String email) async {
    try {
      final docId = await _resolveAthleteDocId(email);
      final doc = await _firestore.collection('athletes').doc(docId).get();
      return doc.data()?['twoFactorEnabled'] == true;
    } catch (e) {
      return false;
    }
  }
}

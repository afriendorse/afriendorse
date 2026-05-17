// lib/feature/referral/repository/referral_tracking_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'user_referral_code_service.dart';

class ReferralData {
  final String? id;
  final String referralCode;
  final String referrerId;
  final String referrerType;
  final String refereeId;
  final String refereeType;
  final String status;
  final DateTime? createdAt;
  final DateTime? completedAt;

  ReferralData({
    this.id,
    required this.referralCode,
    required this.referrerId,
    required this.referrerType,
    required this.refereeId,
    required this.refereeType,
    this.status = 'pending',
    this.createdAt,
    this.completedAt,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json, String docId) {
    return ReferralData(
      id: docId,
      referralCode: json['referralCode'] ?? '',
      referrerId: json['referrerId'] ?? '',
      referrerType: json['referrerType'] ?? '',
      refereeId: json['refereeId'] ?? '',
      refereeType: json['refereeType'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      completedAt: (json['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'referrerId': referrerId,
      'referrerType': referrerType,
      'refereeId': refereeId,
      'refereeType': refereeType,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }
}

class ReferralTrackingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionName = 'referrals';

  /// Track a new referral
  static Future<String?> trackReferral({
    required String referralCode,
    required String refereeEmail,
    required String refereeType, // 'brand' | 'fan' | 'athlete'
  }) async {
    try {
      // Validate referral code and get referrer info
      final referrerInfo = await UserReferralCodeService.validateReferralCode(
        referralCode,
      );

      if (referrerInfo == null) {
        if (kDebugMode) print('❌ Invalid referral code: $referralCode');
        return null;
      }

      // Don't allow self-referral
      if (referrerInfo['userId'] == refereeEmail.trim().toLowerCase()) {
        if (kDebugMode) print('❌ Self-referral not allowed');
        return null;
      }

      final referralData = ReferralData(
        referralCode: referralCode.trim().toUpperCase(),
        referrerId: referrerInfo['userId'],
        referrerType: referrerInfo['userType'],
        refereeId: refereeEmail.trim().toLowerCase(),
        refereeType: refereeType,
        status: 'pending',
      );

      final docRef = await _db
          .collection(_collectionName)
          .add(referralData.toJson());

      // Increment referrer's total referral count
      await UserReferralCodeService.incrementReferralCount(
        referrerEmail: referrerInfo['userId'],
        isSuccessful: false,
      );

      if (kDebugMode) {
        print('✅ Referral tracked: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) print('❌ Error tracking referral: $e');
      return null;
    }
  }

  /// Mark referral as completed
  static Future<bool> completeReferral({required String refereeEmail}) async {
    try {
      final docId = refereeEmail.trim().toLowerCase();

      // Find pending referral for this referee
      final snapshot = await _db
          .collection(_collectionName)
          .where('refereeId', isEqualTo: docId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        if (kDebugMode) print('ℹ️ No pending referral found for $refereeEmail');
        return false;
      }

      final referralDoc = snapshot.docs.first;
      final referrerId = referralDoc.data()['referrerId'];

      // Update referral status
      await referralDoc.reference.set({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Increment successful referral count
      await UserReferralCodeService.incrementReferralCount(
        referrerEmail: referrerId,
        isSuccessful: true,
      );

      if (kDebugMode) {
        print('✅ Referral completed for $refereeEmail');
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error completing referral: $e');
      return false;
    }
  }

  /// Get all referrals made by a user
  static Future<List<ReferralData>> getUserReferrals(String userEmail) async {
    try {
      final docId = userEmail.trim().toLowerCase();

      final snapshot = await _db
          .collection(_collectionName)
          .where('referrerId', isEqualTo: docId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReferralData.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching user referrals: $e');
      return [];
    }
  }

  /// Stream user's referrals
  static Stream<List<ReferralData>> streamUserReferrals(String userEmail) {
    final docId = userEmail.trim().toLowerCase();

    return _db
        .collection(_collectionName)
        .where('referrerId', isEqualTo: docId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReferralData.fromJson(doc.data(), doc.id))
              .toList();
        });
  }
}

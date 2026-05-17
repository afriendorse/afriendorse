// lib/feature/referral/repository/user_referral_code_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'referral_code_generator.dart';

class UserReferralCodeData {
  final String userId;
  final String userType;
  final String referralCode;
  final int totalReferrals;
  final int successfulReferrals;
  final double totalPointsEarned;
  final double totalCommissionEarned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserReferralCodeData({
    required this.userId,
    required this.userType,
    required this.referralCode,
    this.totalReferrals = 0,
    this.successfulReferrals = 0,
    this.totalPointsEarned = 0,
    this.totalCommissionEarned = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory UserReferralCodeData.fromJson(Map<String, dynamic> json) {
    return UserReferralCodeData(
      userId: json['userId'] ?? '',
      userType: json['userType'] ?? '',
      referralCode: json['referralCode'] ?? '',
      totalReferrals: json['totalReferrals'] ?? 0,
      successfulReferrals: json['successfulReferrals'] ?? 0,
      totalPointsEarned:
          double.tryParse(json['totalPointsEarned'].toString()) ?? 0,
      totalCommissionEarned:
          double.tryParse(json['totalCommissionEarned'].toString()) ?? 0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userType': userType,
      'referralCode': referralCode,
      'totalReferrals': totalReferrals,
      'successfulReferrals': successfulReferrals,
      'totalPointsEarned': totalPointsEarned,
      'totalCommissionEarned': totalCommissionEarned,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class UserReferralCodeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionName = 'user_referral_codes';

  /// Create or get referral code for user
  static Future<String> getOrCreateReferralCode({
    required String email,
    required String userType,
    required String firstName,
  }) async {
    try {
      final docId = email.trim().toLowerCase();
      final doc = await _db.collection(_collectionName).doc(docId).get();

      if (doc.exists) {
        return doc.data()?['referralCode'] ?? '';
      }

      // Generate new code
      final code = await ReferralCodeGenerator.generateUniqueCode(
        firstName: firstName,
        email: email,
      );

      final data = UserReferralCodeData(
        userId: docId,
        userType: userType,
        referralCode: code,
      );

      await _db.collection(_collectionName).doc(docId).set(data.toJson());

      return code;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting/creating referral code: $e');
      return '';
    }
  }

  /// Get user's referral data
  static Future<UserReferralCodeData?> getUserReferralData(String email) async {
    try {
      final docId = email.trim().toLowerCase();
      final doc = await _db.collection(_collectionName).doc(docId).get();

      if (!doc.exists) return null;

      return UserReferralCodeData.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching user referral data: $e');
      return null;
    }
  }

  /// Stream user's referral data (for real-time updates)
  static Stream<UserReferralCodeData?> streamUserReferralData(String email) {
    final docId = email.trim().toLowerCase();

    return _db.collection(_collectionName).doc(docId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserReferralCodeData.fromJson(doc.data()!);
    });
  }

  /// Validate if referral code exists and get owner info
  static Future<Map<String, dynamic>?> validateReferralCode(String code) async {
    try {
      final snapshot = await _db
          .collection(_collectionName)
          .where('referralCode', isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data();
      return {
        'userId': data['userId'],
        'userType': data['userType'],
        'referralCode': data['referralCode'],
      };
    } catch (e) {
      if (kDebugMode) print('❌ Error validating referral code: $e');
      return null;
    }
  }

  /// Increment referral count
  static Future<void> incrementReferralCount({
    required String referrerEmail,
    bool isSuccessful = false,
  }) async {
    try {
      final docId = referrerEmail.trim().toLowerCase();

      await _db.collection(_collectionName).doc(docId).set({
        'totalReferrals': FieldValue.increment(1),
        if (isSuccessful) 'successfulReferrals': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('❌ Error incrementing referral count: $e');
    }
  }

  /// Update earnings
  static Future<void> updateEarnings({
    required String userEmail,
    double? points,
    double? commission,
  }) async {
    try {
      final docId = userEmail.trim().toLowerCase();

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (points != null && points > 0) {
        updates['totalPointsEarned'] = FieldValue.increment(points);
      }

      if (commission != null && commission > 0) {
        updates['totalCommissionEarned'] = FieldValue.increment(commission);
      }

      await _db
          .collection(_collectionName)
          .doc(docId)
          .set(updates, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('❌ Error updating earnings: $e');
    }
  }

  /// Deduct points from user's total (for withdrawals)
  /// Deduct points from user's total (for withdrawals) — prevents negative balance
  static Future<bool> deductPoints({
    required String userEmail,
    required double points,
  }) async {
    try {
      final docId = userEmail.trim().toLowerCase();
      final doc = await _db.collection(_collectionName).doc(docId).get();

      if (!doc.exists) {
        if (kDebugMode) print('❌ User referral data not found for deduction');
        return false;
      }

      final currentPoints =
          double.tryParse(doc.data()!['totalPointsEarned'].toString()) ?? 0;

      // Prevent negative balance
      if (currentPoints < points) {
        if (kDebugMode) {
          print('❌ Insufficient points: $currentPoints < $points');
        }
        return false;
      }

      final newPoints = currentPoints - points;

      await _db.collection(_collectionName).doc(docId).set({
        'totalPointsEarned': newPoints,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Deducted $points points. New balance: $newPoints');
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error deducting points: $e');
      return false;
    }
  }
}

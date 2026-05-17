// lib/feature/referral/repository/referral_reward_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'referral_settings_service.dart';
import 'user_referral_code_service.dart';

class ReferralReward {
  final String? id;
  final String userId;
  final String userType;
  final String rewardType;
  final double points;
  final double amount;
  final String? bookingId;
  final String? referralId;
  final String status;
  final DateTime? createdAt;
  final DateTime? creditedAt;
  final String? failureReason;

  ReferralReward({
    this.id,
    required this.userId,
    required this.userType,
    required this.rewardType,
    this.points = 0,
    this.amount = 0,
    this.bookingId,
    this.referralId,
    this.status = 'pending',
    this.createdAt,
    this.creditedAt,
    this.failureReason,
  });

  factory ReferralReward.fromJson(Map<String, dynamic> json, String docId) {
    return ReferralReward(
      id: docId,
      userId: json['userId'] ?? '',
      userType: json['userType'] ?? '',
      rewardType: json['rewardType'] ?? '',
      points: double.tryParse(json['points'].toString()) ?? 0,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      bookingId: json['bookingId'],
      referralId: json['referralId'],
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      creditedAt: (json['creditedAt'] as Timestamp?)?.toDate(),
      failureReason: json['failureReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userType': userType,
      'rewardType': rewardType,
      'points': points,
      'amount': amount,
      if (bookingId != null) 'bookingId': bookingId,
      if (referralId != null) 'referralId': referralId,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      if (creditedAt != null) 'creditedAt': Timestamp.fromDate(creditedAt!),
      if (failureReason != null) 'failureReason': failureReason,
    };
  }
}

class ReferralRewardService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionName = 'referral_rewards';

  /// Award points for user-to-user referral (REFERRER)
  static Future<bool> awardUserReferralPoints({
    required String referrerEmail,
    required String referrerType,
    required String refereeEmail,
    required String referralId,
  }) async {
    try {
      final settings = await ReferralSettingsService.getSettings();

      if (!settings.enabled) {
        if (kDebugMode) print('ℹ️ Referral system is disabled');
        return false;
      }

      final points = settings.pointsPerReferral.toDouble();

      final reward = ReferralReward(
        userId: referrerEmail.trim().toLowerCase(),
        userType: referrerType,
        rewardType: 'user_referral_points',
        points: points,
        amount: 0,
        referralId: referralId,
        status: 'pending',
      );

      final docRef = await _db.collection(_collectionName).add(reward.toJson());

      final credited = await _creditPointsReward(
        rewardId: docRef.id,
        userEmail: referrerEmail,
        points: points,
      );

      if (credited) {
        await UserReferralCodeService.updateEarnings(
          userEmail: referrerEmail,
          points: points,
        );
      }

      return credited;
    } catch (e) {
      if (kDebugMode) print('❌ Error awarding user referral points: $e');
      return false;
    }
  }

  /// Award WELCOME points to REFEREE (person who was referred)
  static Future<bool> awardRefereeWelcomePoints({
    required String refereeEmail,
    required String refereeType,
    required String referralId,
  }) async {
    try {
      final settings = await ReferralSettingsService.getSettings();

      if (!settings.enabled) {
        if (kDebugMode) print('ℹ️ Referral system is disabled');
        return false;
      }

      final points = settings.pointsPerReferee.toDouble();

      final reward = ReferralReward(
        userId: refereeEmail.trim().toLowerCase(),
        userType: refereeType,
        rewardType: 'referee_welcome_points',
        points: points,
        amount: 0,
        referralId: referralId,
        status: 'pending',
      );

      final docRef = await _db.collection(_collectionName).add(reward.toJson());

      final credited = await _creditPointsReward(
        rewardId: docRef.id,
        userEmail: refereeEmail,
        points: points,
      );

      if (credited) {
        await UserReferralCodeService.updateEarnings(
          userEmail: refereeEmail,
          points: points,
        );

        if (kDebugMode) {
          print('✅ Referee welcome points awarded: $points to $refereeEmail');
        }
      }

      return credited;
    } catch (e) {
      if (kDebugMode) print('❌ Error awarding referee points: $e');
      return false;
    }
  }

  /// Credit points reward
  static Future<bool> _creditPointsReward({
    required String rewardId,
    required String userEmail,
    required double points,
  }) async {
    try {
      await _db.collection(_collectionName).doc(rewardId).set({
        'status': 'credited',
        'creditedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Points reward credited: $points points to $userEmail');
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error crediting points: $e');

      await _db.collection(_collectionName).doc(rewardId).set({
        'status': 'failed',
        'failureReason': e.toString(),
      }, SetOptions(merge: true));

      return false;
    }
  }

  /// Award commission for brand referral
  static Future<bool> awardBrandCommission({
    required String referrerEmail,
    required String referrerType,
    required String brandEmail,
    required String bookingId,
    required double dealAmount,
  }) async {
    try {
      final settings = await ReferralSettingsService.getSettings();

      if (!settings.enabled) {
        if (kDebugMode) print('ℹ️ Referral system is disabled');
        return false;
      }

      final commissionPercentage = settings.brandCommissionPercentage;
      final commissionAmount = (dealAmount * commissionPercentage) / 100;

      final reward = ReferralReward(
        userId: referrerEmail.trim().toLowerCase(),
        userType: referrerType,
        rewardType: 'brand_commission',
        points: 0,
        amount: commissionAmount,
        bookingId: bookingId,
        status: 'pending',
      );

      final docRef = await _db.collection(_collectionName).add(reward.toJson());

      final credited = await _creditCommissionReward(
        rewardId: docRef.id,
        userEmail: referrerEmail,
        amount: commissionAmount,
      );

      if (credited) {
        await UserReferralCodeService.updateEarnings(
          userEmail: referrerEmail,
          commission: commissionAmount,
        );
      }

      return credited;
    } catch (e) {
      if (kDebugMode) print('❌ Error awarding brand commission: $e');
      return false;
    }
  }

  /// Credit commission to user's wallet
  static Future<bool> _creditCommissionReward({
    required String rewardId,
    required String userEmail,
    required double amount,
  }) async {
    try {
      // Safely get WalletRepo
      late final WalletRepo walletRepo;
      try {
        walletRepo = Get.find<WalletRepo>();
      } catch (_) {
        if (kDebugMode) print('❌ WalletRepo not registered in GetX');
        return false;
      }

      final response = await walletRepo.apiClient.postData(
        AppConstants.walletAddFundsUri,
        {'amount': amount, 'purpose': 'Referral Commission'},
      );

      if (response.statusCode == 200) {
        await _db.collection(_collectionName).doc(rewardId).set({
          'status': 'credited',
          'creditedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (kDebugMode) {
          print('✅ Commission credited: \$$amount to $userEmail wallet');
        }

        customSnackBar('Commission Earned!', type: ToasterMessageType.success);

        return true;
      } else {
        throw Exception('Wallet API error: ${response.statusText}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error crediting commission: $e');

      await _db.collection(_collectionName).doc(rewardId).set({
        'status': 'failed',
        'failureReason': e.toString(),
      }, SetOptions(merge: true));

      return false;
    }
  }

  /// Record points deduction (for withdrawals) — creates negative reward record
  static Future<void> recordPointsDeduction({
    required String userEmail,
    required double points,
    required String purpose,
  }) async {
    try {
      final deduction = ReferralReward(
        userId: userEmail.trim().toLowerCase(),
        userType: 'fan',
        rewardType: 'points_deduction',
        points: -points, // negative to reduce total
        amount: 0,
        status: 'credited', // immediately applied
        createdAt: DateTime.now(),
        creditedAt: DateTime.now(),
      );

      await _db.collection(_collectionName).add(deduction.toJson());

      if (kDebugMode) {
        print('✅ Points deduction recorded: -$points for $purpose');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error recording points deduction: $e');
    }
  }

  /// Get user's rewards history
  static Future<List<ReferralReward>> getUserRewards(String userEmail) async {
    try {
      final docId = userEmail.trim().toLowerCase();

      final snapshot = await _db
          .collection(_collectionName)
          .where('userId', isEqualTo: docId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReferralReward.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching user rewards: $e');
      return [];
    }
  }

  /// Stream user's rewards
  static Stream<List<ReferralReward>> streamUserRewards(String userEmail) {
    final docId = userEmail.trim().toLowerCase();

    return _db
        .collection(_collectionName)
        .where('userId', isEqualTo: docId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReferralReward.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  /// Get total rewards summary
  static Future<Map<String, double>> getRewardsSummary(String userEmail) async {
    try {
      final rewards = await getUserRewards(userEmail);

      double totalPoints = 0;
      double totalCommission = 0;
      double pendingCommission = 0;

      for (var reward in rewards) {
        if (reward.status == 'credited') {
          totalPoints += reward.points;
          totalCommission += reward.amount;
        } else if (reward.status == 'pending' &&
            reward.rewardType == 'brand_commission') {
          pendingCommission += reward.amount;
        }
      }

      return {
        'totalPoints': totalPoints,
        'totalCommission': totalCommission,
        'pendingCommission': pendingCommission,
      };
    } catch (e) {
      if (kDebugMode) print('❌ Error getting rewards summary: $e');
      return {'totalPoints': 0, 'totalCommission': 0, 'pendingCommission': 0};
    }
  }
}

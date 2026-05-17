// lib/feature/referral/repository/brand_commission_tracking_service.dart

import 'package:afriendorse/feature/wallet/repository/wallet_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'referral_settings_service.dart';
import 'referral_reward_service.dart';

class BrandCommissionTrack {
  final String? id;
  final String brandId;
  final String referrerId;
  final String referrerType;
  final String bookingId;
  final double dealAmount;
  final double commissionPercentage;
  final double commissionAmount;
  final DateTime? dealApprovedAt;
  final DateTime? commissionPaidAt;
  final String status; // 'pending' | 'paid' | 'failed'
  final bool isFirstDeal;
  final DateTime? createdAt;

  BrandCommissionTrack({
    this.id,
    required this.brandId,
    required this.referrerId,
    required this.referrerType,
    required this.bookingId,
    required this.dealAmount,
    required this.commissionPercentage,
    required this.commissionAmount,
    this.dealApprovedAt,
    this.commissionPaidAt,
    this.status = 'pending',
    this.isFirstDeal = false,
    this.createdAt,
  });

  factory BrandCommissionTrack.fromJson(
    Map<String, dynamic> json,
    String docId,
  ) {
    return BrandCommissionTrack(
      id: docId,
      brandId: json['brandId'] ?? '',
      referrerId: json['referrerId'] ?? '',
      referrerType: json['referrerType'] ?? '',
      bookingId: json['bookingId'] ?? '',
      dealAmount: double.tryParse(json['dealAmount'].toString()) ?? 0,
      commissionPercentage:
          double.tryParse(json['commissionPercentage'].toString()) ?? 0,
      commissionAmount:
          double.tryParse(json['commissionAmount'].toString()) ?? 0,
      dealApprovedAt: (json['dealApprovedAt'] as Timestamp?)?.toDate(),
      commissionPaidAt: (json['commissionPaidAt'] as Timestamp?)?.toDate(),
      status: json['status'] ?? 'pending',
      isFirstDeal: json['isFirstDeal'] ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brandId': brandId,
      'referrerId': referrerId,
      'referrerType': referrerType,
      'bookingId': bookingId,
      'dealAmount': dealAmount,
      'commissionPercentage': commissionPercentage,
      'commissionAmount': commissionAmount,
      if (dealApprovedAt != null)
        'dealApprovedAt': Timestamp.fromDate(dealApprovedAt!),
      if (commissionPaidAt != null)
        'commissionPaidAt': Timestamp.fromDate(commissionPaidAt!),
      'status': status,
      'isFirstDeal': isFirstDeal,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

class BrandCommissionTrackingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionName = 'brand_commission_tracking';

  /// Process commission when a deal is approved
  static Future<bool> processDealApprovalCommission({
    required String bookingId,
    required String brandEmail,
    required double dealAmount,
  }) async {
    try {
      // Ensure WalletRepo is registered before processing
      if (!Get.isRegistered<WalletRepo>()) {
        Get.lazyPut(
          () =>
              WalletRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
        );
      }

      // Find if this brand was referred
      final referralSnapshot = await _db
          .collection('referrals')
          .where('refereeId', isEqualTo: brandEmail.trim().toLowerCase())
          .where('refereeType', isEqualTo: 'brand')
          .where('status', isEqualTo: 'completed')
          .limit(1)
          .get();

      if (referralSnapshot.docs.isEmpty) {
        if (kDebugMode) print('ℹ️ No referral found for brand $brandEmail');
        return false;
      }

      final referralData = referralSnapshot.docs.first.data();
      final referrerId = referralData['referrerId'] as String;
      final referrerType = referralData['referrerType'] as String;

      final settings = await ReferralSettingsService.getSettings();

      // Check commission type (one-time or recurring)
      final isOneTime = settings.brandCommissionType == 'one_time';

      if (isOneTime) {
        // Check if this brand already had a commission paid
        final existingCommission = await _db
            .collection(_collectionName)
            .where('brandId', isEqualTo: brandEmail.trim().toLowerCase())
            .where('status', isEqualTo: 'paid')
            .limit(1)
            .get();

        if (existingCommission.docs.isNotEmpty) {
          if (kDebugMode) {
            print('ℹ️ One-time commission already paid for brand $brandEmail');
          }
          return false;
        }
      }

      // Check if this is the first deal
      final allDeals = await _db
          .collection(_collectionName)
          .where('brandId', isEqualTo: brandEmail.trim().toLowerCase())
          .get();

      final isFirstDeal = allDeals.docs.isEmpty;

      final commissionPercentage = settings.brandCommissionPercentage;
      final commissionAmount = (dealAmount * commissionPercentage) / 100;

      // Create commission tracking record
      final track = BrandCommissionTrack(
        brandId: brandEmail.trim().toLowerCase(),
        referrerId: referrerId,
        referrerType: referrerType,
        bookingId: bookingId,
        dealAmount: dealAmount,
        commissionPercentage: commissionPercentage,
        commissionAmount: commissionAmount,
        dealApprovedAt: DateTime.now(),
        status: 'pending',
        isFirstDeal: isFirstDeal,
      );

      final docRef = await _db.collection(_collectionName).add(track.toJson());

      // Award commission to referrer
      final awarded = await ReferralRewardService.awardBrandCommission(
        referrerEmail: referrerId,
        referrerType: referrerType,
        brandEmail: brandEmail,
        bookingId: bookingId,
        dealAmount: dealAmount,
      );

      if (awarded) {
        // Mark as paid
        await docRef.set({
          'status': 'paid',
          'commissionPaidAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (kDebugMode) {
          print(
            '✅ Commission processed: \$$commissionAmount for deal $bookingId',
          );
        }
      }

      return awarded;
    } catch (e) {
      if (kDebugMode) print('❌ Error processing deal commission: $e');
      return false;
    }
  }

  /// Get brand's commission history
  static Future<List<BrandCommissionTrack>> getBrandCommissions(
    String brandEmail,
  ) async {
    try {
      final docId = brandEmail.trim().toLowerCase();

      final snapshot = await _db
          .collection(_collectionName)
          .where('brandId', isEqualTo: docId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BrandCommissionTrack.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching brand commissions: $e');
      return [];
    }
  }

  /// Get referrer's commission earnings from brands they referred
  static Future<List<BrandCommissionTrack>> getReferrerCommissions(
    String referrerEmail,
  ) async {
    try {
      final docId = referrerEmail.trim().toLowerCase();

      final snapshot = await _db
          .collection(_collectionName)
          .where('referrerId', isEqualTo: docId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BrandCommissionTrack.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching referrer commissions: $e');
      return [];
    }
  }

  /// Stream referrer's commissions
  static Stream<List<BrandCommissionTrack>> streamReferrerCommissions(
    String referrerEmail,
  ) {
    final docId = referrerEmail.trim().toLowerCase();

    return _db
        .collection(_collectionName)
        .where('referrerId', isEqualTo: docId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BrandCommissionTrack.fromJson(doc.data(), doc.id))
              .toList();
        });
  }
}

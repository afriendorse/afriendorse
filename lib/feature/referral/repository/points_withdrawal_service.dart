// lib/feature/referral/repository/points_withdrawal_service.dart

import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';
import 'package:afriendorse/athlete/feature/wallet/widgets/athlete_wallet_overlay_service.dart';
import 'package:afriendorse/feature/referral/repository/referral_reward_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'referral_settings_service.dart';
import 'user_referral_code_service.dart';

class PointsWithdrawal {
  final String? id;
  final String userId;
  final String userEmail;
  final double pointsAmount;
  final double cashAmount;
  final int conversionRate;
  final String status;
  final DateTime? requestedAt;
  final DateTime? processedAt;
  final String? transactionId;
  final String? rejectionReason;
  final String? notes;

  PointsWithdrawal({
    this.id,
    required this.userId,
    required this.userEmail,
    required this.pointsAmount,
    required this.cashAmount,
    required this.conversionRate,
    this.status = 'pending',
    this.requestedAt,
    this.processedAt,
    this.transactionId,
    this.rejectionReason,
    this.notes,
  });

  factory PointsWithdrawal.fromJson(Map<String, dynamic> json, String docId) {
    return PointsWithdrawal(
      id: docId,
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      pointsAmount: double.tryParse(json['pointsAmount'].toString()) ?? 0,
      cashAmount: double.tryParse(json['cashAmount'].toString()) ?? 0,
      conversionRate: json['conversionRate'] ?? 100,
      status: json['status'] ?? 'pending',
      requestedAt: (json['requestedAt'] as Timestamp?)?.toDate(),
      processedAt: (json['processedAt'] as Timestamp?)?.toDate(),
      transactionId: json['transactionId'],
      rejectionReason: json['rejectionReason'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'pointsAmount': pointsAmount,
      'cashAmount': cashAmount,
      'conversionRate': conversionRate,
      'status': status,
      'requestedAt': requestedAt != null
          ? Timestamp.fromDate(requestedAt!)
          : FieldValue.serverTimestamp(),
      if (processedAt != null) 'processedAt': Timestamp.fromDate(processedAt!),
      if (transactionId != null) 'transactionId': transactionId,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (notes != null) 'notes': notes,
    };
  }
}

class PointsWithdrawalService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionName = 'points_withdrawals';

  static Future<Map<String, dynamic>> requestWithdrawal({
    required String userEmail,
    required double pointsAmount,
  }) async {
    try {
      final settings = await ReferralSettingsService.getSettings();

      if (!settings.withdrawalEnabled) {
        return {
          'success': false,
          'message': 'Points withdrawal is currently disabled',
        };
      }

      final rewardsSummary = await ReferralRewardService.getRewardsSummary(
        userEmail,
      );
      final availablePoints = rewardsSummary['totalPoints'] ?? 0.0;

      if (availablePoints <= 0) {
        return {
          'success': false,
          'message': 'No points available for withdrawal',
        };
      }

      if (pointsAmount < settings.minimumWithdrawalPoints) {
        return {
          'success': false,
          'message':
              'Minimum withdrawal is ${settings.minimumWithdrawalPoints} points',
        };
      }

      if (pointsAmount > settings.maximumWithdrawalPoints) {
        return {
          'success': false,
          'message':
              'Maximum withdrawal is ${settings.maximumWithdrawalPoints} points',
        };
      }

      if (pointsAmount > availablePoints) {
        return {
          'success': false,
          'message':
              'Insufficient points. You have ${availablePoints.toInt()} points',
        };
      }

      final todayWithdrawals = await _getTodayWithdrawals(userEmail);
      final todayTotal = todayWithdrawals.fold<double>(
        0,
        (sum, w) => sum + w.pointsAmount,
      );

      if (todayTotal + pointsAmount > settings.dailyWithdrawalLimit) {
        final remaining = settings.dailyWithdrawalLimit - todayTotal;
        return {
          'success': false,
          'message':
              'Daily limit reached. You can withdraw ${remaining.toInt()} more points today',
        };
      }

      final cashAmount = settings.pointsToCash(pointsAmount);

      final withdrawal = PointsWithdrawal(
        userId: userEmail.trim().toLowerCase(),
        userEmail: userEmail.trim().toLowerCase(),
        pointsAmount: pointsAmount,
        cashAmount: cashAmount,
        conversionRate: settings.pointsConversionRate,
        status: 'pending',
      );

      final docRef = await _db
          .collection(_collectionName)
          .add(withdrawal.toJson());

      if (!settings.requiresAdminApproval ||
          cashAmount <= settings.autoApprovalThreshold) {
        final processed = await _processWithdrawal(
          withdrawalId: docRef.id,
          userEmail: userEmail,
          pointsAmount: pointsAmount,
          cashAmount: cashAmount,
        );

        if (processed) {
          return {
            'success': true,
            'message':
                'Withdrawal processed! \$${cashAmount.toStringAsFixed(2)} added to your wallet',
            'withdrawalId': docRef.id,
            'autoApproved': true,
          };
        } else {
          return {
            'success': false,
            'message': 'Failed to process withdrawal. Please try again',
          };
        }
      } else {
        return {
          'success': true,
          'message': 'Withdrawal request submitted for approval',
          'withdrawalId': docRef.id,
          'autoApproved': false,
        };
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error requesting withdrawal: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  static Future<bool> _processWithdrawal({
    required String withdrawalId,
    required String userEmail,
    required double pointsAmount,
    required double cashAmount,
  }) async {
    final athleteData = await AthleteFirestoreSyncService.getAthleteByEmail(
      userEmail,
    );
    final isAthlete = athleteData != null;

    if (isAthlete) {
      return _processAthleteWithdrawal(
        withdrawalId: withdrawalId,
        userEmail: userEmail,
        pointsAmount: pointsAmount,
        cashAmount: cashAmount,
        athleteData: athleteData,
      );
    } else {
      return _processBrandFanWithdrawal(
        withdrawalId: withdrawalId,
        userEmail: userEmail,
        pointsAmount: pointsAmount,
        cashAmount: cashAmount,
      );
    }
  }

  /// Athlete path: credits overlay + writes wallet transaction doc for history
  static Future<bool> _processAthleteWithdrawal({
    required String withdrawalId,
    required String userEmail,
    required double pointsAmount,
    required double cashAmount,
    required Map<String, dynamic> athleteData,
  }) async {
    try {
      final mysqlAthleteId = (athleteData['mysqlAthleteId'] ?? '')
          .toString()
          .trim();

      if (mysqlAthleteId.isEmpty) {
        if (kDebugMode) {
          print('❌ mysqlAthleteId missing for athlete: $userEmail');
        }

        await _db.collection(_collectionName).doc(withdrawalId).set({
          'status': 'rejected',
          'rejectionReason': 'Athlete wallet ID not found',
          'processedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return false;
      }

      final txDocId = 'pts_withdrawal_$withdrawalId';
      final nowTs = Timestamp.now();

      // 1. Credit cash to athlete's wallet overlay (idempotent)
      await AthleteWalletOverlayService.applyDonation(
        mysqlAthleteId: mysqlAthleteId,
        paystackRef: txDocId,
        amount: cashAmount,
        athleteEmailLower: userEmail.trim().toLowerCase(),
      );

      // 2. Write wallet transaction doc so it appears in history UI
      await FirebaseFirestore.instance
          .collection('wallet_transactions')
          .doc(userEmail.trim().toLowerCase())
          .collection('transactions')
          .doc(txDocId)
          .set({
            'type': 'pointsWithdrawal',
            'amount': cashAmount,
            'title': 'Points Redeemed',
            'subtitle':
                '${pointsAmount.toInt()} pts → \$${cashAmount.toStringAsFixed(2)}',
            'reference': withdrawalId,
            'status': 'completed',
            'createdAt': nowTs,
            'metadata': {
              'withdrawalId': withdrawalId,
              'pointsAmount': pointsAmount,
              'cashAmount': cashAmount,
              'mysqlAthleteId': mysqlAthleteId,
              'walletPath': 'overlay',
              'source': 'referral_points',
            },
          }, SetOptions(merge: true));

      // 3. Deduct points from referral rewards (source of truth for points UI)
      await ReferralRewardService.recordPointsDeduction(
        userEmail: userEmail,
        points: pointsAmount,
        purpose: 'Points Withdrawal',
      );

      // 4. Mark withdrawal record complete
      await _db.collection(_collectionName).doc(withdrawalId).set({
        'status': 'completed',
        'processedAt': FieldValue.serverTimestamp(),
        'transactionId': txDocId,
        'mysqlAthleteId': mysqlAthleteId,
        'walletPath': 'overlay',
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print(
          '✅ Athlete withdrawal: ${pointsAmount}pts → \$${cashAmount.toStringAsFixed(2)} credited + recorded [$mysqlAthleteId]',
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ _processAthleteWithdrawal error: $e');

      await _db.collection(_collectionName).doc(withdrawalId).set({
        'status': 'rejected',
        'rejectionReason': e.toString(),
        'processedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return false;
    }
  }

  /// Brand/Fan path: credits via WalletRepo API (original behaviour, untouched)
  static Future<bool> _processBrandFanWithdrawal({
    required String withdrawalId,
    required String userEmail,
    required double pointsAmount,
    required double cashAmount,
  }) async {
    try {
      late final WalletRepo walletRepo;
      try {
        walletRepo = Get.find<WalletRepo>();
      } catch (_) {
        if (kDebugMode) print('❌ WalletRepo not registered in GetX');

        await _db.collection(_collectionName).doc(withdrawalId).set({
          'status': 'rejected',
          'rejectionReason': 'Wallet service unavailable',
          'processedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return false;
      }

      final response = await walletRepo.apiClient.postData(
        AppConstants.walletAddFundsUri,
        {'amount': cashAmount, 'purpose': 'Points Withdrawal'},
      );

      if (response.statusCode == 200) {
        await ReferralRewardService.recordPointsDeduction(
          userEmail: userEmail,
          points: pointsAmount,
          purpose: 'Points Withdrawal',
        );

        await _db.collection(_collectionName).doc(withdrawalId).set({
          'status': 'completed',
          'processedAt': FieldValue.serverTimestamp(),
          'transactionId':
              response.body['content']?['transaction_id'] ??
              'TXN_${DateTime.now().millisecondsSinceEpoch}',
          'walletPath': 'api',
        }, SetOptions(merge: true));

        if (kDebugMode) {
          print(
            '✅ Brand/Fan withdrawal: ${pointsAmount}pts → \$${cashAmount.toStringAsFixed(2)} credited via API',
          );
        }

        return true;
      } else {
        await _db.collection(_collectionName).doc(withdrawalId).set({
          'status': 'rejected',
          'rejectionReason': 'Wallet API error: ${response.statusText}',
          'processedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return false;
      }
    } catch (e) {
      if (kDebugMode) print('❌ _processBrandFanWithdrawal error: $e');

      await _db.collection(_collectionName).doc(withdrawalId).set({
        'status': 'rejected',
        'rejectionReason': e.toString(),
        'processedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return false;
    }
  }

  static Future<List<PointsWithdrawal>> getWithdrawalHistory(
    String userEmail,
  ) async {
    try {
      final docId = userEmail.trim().toLowerCase();

      final snapshot = await _db
          .collection(_collectionName)
          .where('userId', isEqualTo: docId)
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PointsWithdrawal.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching withdrawal history: $e');
      return [];
    }
  }

  static Future<List<PointsWithdrawal>> _getTodayWithdrawals(
    String userEmail,
  ) async {
    try {
      final docId = userEmail.trim().toLowerCase();
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final snapshot = await _db
          .collection(_collectionName)
          .where('userId', isEqualTo: docId)
          .where(
            'requestedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('status', whereIn: ['pending', 'approved', 'completed'])
          .get();

      return snapshot.docs
          .map((doc) => PointsWithdrawal.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching today withdrawals: $e');
      return [];
    }
  }

  static Stream<List<PointsWithdrawal>> streamWithdrawalHistory(
    String userEmail,
  ) {
    final docId = userEmail.trim().toLowerCase();

    return _db
        .collection(_collectionName)
        .where('userId', isEqualTo: docId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PointsWithdrawal.fromJson(doc.data(), doc.id))
              .toList();
        });
  }
}

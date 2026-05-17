// lib/athlete/feature/campaigns/repository/athlete_wallet_donation_service.dart
//
// Athlete-only: Donate to campaigns using wallet balance.
// Completely separate from brand/fan wallet donation flow.
// Uses AthleteWalletOverlayService to track spends without touching SQL backend.

import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/repository/campaign_firestore_service.dart';
import 'package:afriendorse/athlete/feature/wallet/widgets/athlete_wallet_overlay_service.dart';
import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AthleteWalletDonationService {
  /// Check if athlete has enough spendable balance
  static Future<bool> hasEnoughBalance({
    required String athleteEmailLower,
    required double amount,
  }) async {
    try {
      final spendable = await _getSpendableBalance(athleteEmailLower);
      return spendable >= amount;
    } catch (e) {
      if (kDebugMode) print('[AthleteWalletDonation] balance check error: $e');
      return false;
    }
  }

  /// Get spendable balance: SQL available + donation overlay - total spent
  static Future<double> _getSpendableBalance(String athleteEmailLower) async {
    try {
      final athlete = await AthleteFirestoreSyncService.getAthleteByEmail(
        athleteEmailLower,
      );
      final mId = (athlete?['mysqlAthleteId'] ?? '').toString().trim();
      if (mId.isEmpty) return 0;

      // Get SQL available balance (from UserProfileController)
      double sqlBalance = 0;
      try {
        final ctrl = Get.find<UserProfileController>();
        sqlBalance =
            double.tryParse(
              ctrl
                      .providerModel
                      ?.content
                      ?.providerInfo
                      ?.owner
                      ?.account
                      ?.accountReceivable ??
                  '0',
            ) ??
            0;
      } catch (_) {}

      // Get donation overlay balance
      final overlayDoc = await FirebaseFirestore.instance
          .collection('athlete_wallet_overlays')
          .doc(mId)
          .get();
      final overlayBalance = (overlayDoc.data()?['donationBalance'] ?? 0)
          .toDouble();

      // Get total spent
      final totalSpent = (overlayDoc.data()?['totalSpent'] ?? 0).toDouble();

      return sqlBalance + overlayBalance - totalSpent;
    } catch (e) {
      if (kDebugMode) print('[AthleteWalletDonation] spendable calc error: $e');
      return 0;
    }
  }

  /// Execute wallet donation: deduct from athlete wallet, create donation record, complete it
  static Future<bool> donate({
    required String athleteEmailLower,
    required String athleteName,
    required String athleteId, // email or user id
    required CampaignModel campaign,
    required double amount,
    required bool isAnonymous,
    String? message,
  }) async {
    try {
      // 1. Verify sufficient balance
      final hasEnough = await hasEnoughBalance(
        athleteEmailLower: athleteEmailLower,
        amount: amount,
      );
      if (!hasEnough) return false;

      // 2. Resolve mysqlAthleteId
      final athlete = await AthleteFirestoreSyncService.getAthleteByEmail(
        athleteEmailLower,
      );
      final mId = (athlete?['mysqlAthleteId'] ?? '').toString().trim();
      if (mId.isEmpty) return false;

      // 3. Record the spend (idempotent)
      final spendRef =
          'athlete_donation_${campaign.id}_${DateTime.now().millisecondsSinceEpoch}';
      final spent = await AthleteWalletOverlayService.recordSpend(
        mysqlAthleteId: mId,
        spendRef: spendRef,
        amount: amount,
        athleteEmailLower: athleteEmailLower,
        reason: 'athlete_campaign_donation|${campaign.id}|${campaign.title}',
      );
      if (!spent) return false;

      // 4. Create donation record in campaign_donations
      final donationId = await CampaignFirestoreService.initiateDonation(
        campaignId: campaign.id,
        campaignTitle: campaign.title,
        athleteId: campaign.creatorId,
        athleteName: campaign.creatorName,
        groupId: campaign.groupId,
        donorId: athleteId,
        donorName: isAnonymous ? 'Anonymous' : athleteName,
        donorEmail: athleteEmailLower,
        amount: amount,
        frequency: DonationFrequency.oneTime,
        isAnonymous: isAnonymous,
        message: message,
      );

      if (donationId == null) {
        // Spend recorded but donation failed — support can trace via spent_refs
        if (kDebugMode) {
          print(
            '[AthleteWalletDonation] CRITICAL: spend recorded but donation init failed. '
            'Ref: $spendRef',
          );
        }
        return false;
      }

      // 5. Complete donation immediately
      final completed = await CampaignFirestoreService.completeDonation(
        donationId: donationId,
        transactionRef: spendRef, // use spendRef as the transaction reference
      );

      return completed;
    } catch (e) {
      if (kDebugMode) print('[AthleteWalletDonation] donate error: $e');
      return false;
    }
  }
}
